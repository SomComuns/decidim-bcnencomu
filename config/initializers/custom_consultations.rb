# frozen_string_literal: true

# Custom consultation rules
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity:
Rails.application.config.to_prepare do
  # /app/helpers/decidim/consultations/questions_helper.rb
  # hide buttons if no next
  Decidim::Consultations::QuestionsHelper.class_eval do
    def display_next_previous_button(direction, optional_classes = "")
      css = "card__button button hollow #{optional_classes}"

      case direction
      when :previous
        return "" if previous_question.nil?

        i18n_text = t("previous_button", scope: "decidim.questions")
        question = previous_question || current_question
        css << " disabled" if previous_question.nil?
      when :next
        return "" if next_question.nil?

        i18n_text = t("next_button", scope: "decidim.questions")
        question = next_question || current_question
        css << " disabled" if next_question.nil?
      end

      link_to(i18n_text, decidim_consultations.question_path(question), class: css)
    end
  end

  # /app/models/decidim/consultations/response.rb
  # Admin check suplent number
  Decidim::Consultations::Response.class_eval do
    def suplent?(lang)
      return unless title[lang].is_a?(String)

      title[lang]&.match(/([\-( ]+)(suplente?)([\-) ]+)/i)
    end

    def blanc?(lang)
      return unless title[lang].is_a?(String)

      title[lang]&.match(/([\-( ]+)(blanco?)([\-) ]+)/i)
    end

    def weighted_votes_count
      return votes_count unless response_group&.complete_list? && question.is_weighted?

      votes_count + (response_group.complete_votes_count * 0.2)
    end
  end

  # /app/models/decidim/consultations/question.rb
  Decidim::Consultations::Question.class_eval do
    # Ensure order by time
    def sorted_responses
      responses.order(decidim_consultations_response_group_id: :asc, created_at: :asc)
    end

    def get_blancs(lang)
      responses.select do |r|
        r.blanc?(lang)
      end
    end

    def get_suplents(lang)
      responses.select do |r|
        r.suplent?(lang)
      end
    end

    def has_suplents?
      @has_suplents ||= title.find { |l, _t| get_suplents(l).count.positive? }.present?
    end

    def has_blancs?
      @has_blancs ||= title.find { |l, _t| get_blancs(l).count.positive? }.present?
    end

    def sorted_results
      return responses.order(votes_count: :desc) unless is_weighted?

      responses.sort_by(&:weighted_votes_count).reverse
    end

    def most_voted_response
      @most_voted_response ||= sorted_results.first
    end
  end

  # /app/models/decidim/consultations/response_group.rb
  Decidim::Consultations::ResponseGroup.class_eval do
    def complete_list?
      # If there are substitutes, validate they match min_votes
      if question.has_suplents?
        question.max_votes == responses.count && question.min_votes == suplents.count
      else
        # If no substitutes, only validate all responses in the group are voted
        question.max_votes == responses.count
      end
    end

    def suplents
      responses.select { |r| r.suplent? "ca" }
    end

    def complete_votes_count
      Rails.cache.fetch("response_group/#{id}/complete_votes_count##{complete_votes_cache_time}", expires_in: 1.day) do
        query = <<-SQL.squish
          SELECT COUNT(*)
          FROM (
            SELECT v.decidim_author_id, COUNT(*) AS votes
            FROM decidim_consultations_votes v
            JOIN decidim_consultations_responses r ON v.decidim_consultations_response_id = r.id
            JOIN decidim_consultations_questions q ON v.decidim_consultation_question_id = q.id
            WHERE v.decidim_consultation_question_id = #{question.id} AND r.decidim_consultations_response_group_id = #{id}
            GROUP BY v.decidim_author_id
          ) a
          WHERE a.votes = #{question.max_votes};
        SQL

        ActiveRecord::Base.connection.execute(Arel.sql(query))[0]["count"].to_i
      end
    end

    private

    def complete_votes_cache_time
      [question.votes.maximum(:updated_at).to_i, question.updated_at.to_i].max
    end
  end

  # /app/controllers/decidim/consultations/admin/responses_controller.rb
  Decidim::Consultations::Admin::ResponsesController.class_eval do
    def index
      enforce_permission_to :read, :response
      return unless current_question.multiple?

      suplents = []
      current_question.title.each do |l, _t|
        suplents << l if current_question.get_suplents(l).count < current_question.min_votes.to_i
      end
      blancs = []
      current_question.title.each do |l, _t|
        blancs << l if current_question.get_blancs(l).count.zero?
      end

      if current_question.has_suplents?
        flash.now[:alert] = "El numero de suplents en els idiomes [#{suplents.join(", ")}] es inferior a #{current_question.min_votes}" if suplents.present?
      else
        flash.now[:warning] = "No s'han detectat suplents en questa votació. S'amagarà la informació relativa als suplents."
      end

      if current_question.has_blancs?
        flash.now[:alert] = "Falta indicar vot en blanc en els idiomes [#{blancs.join(", ")}]" if blancs.present?
      else
        flash.now[:warning] = "No s'han detectat vots en blanc."
      end
    end
  end

  # /app/commands/decidim/consultations/admin/create_question.rb
  Decidim::Consultations::Admin::CreateQuestion.class_eval do
    private

    def create_question
      question = Decidim::Consultations::Question.new(
        consultation: form.context.current_consultation,
        organization: form.context.current_consultation.organization,
        decidim_scope_id: form.decidim_scope_id,
        title: form.title,
        slug: form.slug,
        subtitle: form.subtitle,
        what_is_decided: form.what_is_decided,
        promoter_group: form.promoter_group,
        participatory_scope: form.participatory_scope,
        question_context: form.question_context,
        hashtag: form.hashtag,
        hero_image: form.hero_image,
        banner_image: form.banner_image,
        origin_scope: form.origin_scope,
        origin_title: form.origin_title,
        origin_url: form.origin_url,
        external_voting: form.external_voting,
        i_frame_url: form.i_frame_url,
        order: form.order,
        is_weighted: form.is_weighted
      )

      return question unless question.valid?

      question.save
      question
    end
  end

  # /app/commands/decidim/consultations/admin/update_question.rb
  Decidim::Consultations::Admin::UpdateQuestion.class_eval do
    private

    def attributes
      {
        decidim_scope_id: form.decidim_scope_id,
        title: form.title,
        subtitle: form.subtitle,
        slug: form.slug,
        what_is_decided: form.what_is_decided,
        promoter_group: form.promoter_group,
        participatory_scope: form.participatory_scope,
        question_context: form.question_context,
        hashtag: form.hashtag,
        origin_scope: form.origin_scope,
        origin_title: form.origin_title,
        origin_url: form.origin_url,
        external_voting: form.external_voting,
        i_frame_url: form.i_frame_url,
        order: form.order,
        is_weighted: form.is_weighted
      }.merge(
        attachment_attributes(:hero_image, :banner_image)
      )
    end
  end

  # /app/forms/decidim/consultations/admin/question_form.rb
  Decidim::Consultations::Admin::QuestionForm.class_eval do
    attribute :is_weighted, :boolean, default: false
  end

  # /app/forms/decidim/consultations/multi_vote_form.rb
  # Admin validation customization
  # Decidim::Consultations::Admin::QuestionConfigurationForm.class_eval do
  #   def min_lower_than_max
  #     errors.add(:max_votes, 'Let\'s fail always!')
  #   end
  # end
  #
  # Vote validation override
  Decidim::Consultations::MultiVoteForm.class_eval do
    def locale
      # I18n.locale.to_s
      "ca"
    end

    private

    # rubocop:disable Metrics/BlockNesting
    def valid_num_of_votes
      Rails.logger.debug "===VOTE==="
      @question = context&.current_question
      if @question
        if @question.has_suplents?
          return if num_votes_ok?(vote_forms) || group_ok?(vote_forms) || blanc?(vote_forms)
        else
          if get_blancs(vote_forms).count.positive?
            Rails.logger.debug { "===has blanc: Number of votes #{vote_forms.count} allowed 1" }
            return if vote_forms.count == 1
          end
          Rails.logger.debug { "===has no supplents: Number of votes #{vote_forms.count} allowed [#{@question.max_votes}, #{@question.min_votes}]" }
          return if vote_forms.count.between?(@question.min_votes, @question.max_votes)
        end
      end
      Rails.logger.debug "===ERROR=== Invalid number of votes"
      errors.add(
        :responses,
        I18n.t("activerecord.errors.models.decidim/consultations/vote.attributes.question.invalid_num_votes")
      )
    end
    # rubocop:enable Metrics/BlockNesting

    def blanc?(forms)
      Rails.logger.debug { "===blanc? Total blancs #{get_blancs(forms).count} total forms #{forms.count}" }
      (get_blancs(forms).count == forms.count) && forms.count.positive?
    end

    def group_ok?(forms)
      groups = forms.map { |f| f.response.response_group&.id }.uniq
      Rails.logger.debug { "===group_ok? groups found #{groups.count}, group ids #{groups}" }
      return false if groups.count > 1 || groups.count.zero? || groups[0].blank?

      # max votable titular/suplents in this group
      valid = @question.responses.select { |r| r.response_group&.id == groups[0] }
      valid_suplents = valid.select { |r| r.suplent? locale }.count
      min_titulars = [valid.count - valid_suplents, @question.max_votes - @question.min_votes].min
      min_suplents = [valid_suplents, @question.min_votes].min
      total_titulars = get_candidats(forms).count
      total_suplents = get_suplents(forms).count

      Rails.logger.debug { "===group_ok? Total titulars in group #{groups[0]}: #{total_titulars} expected #{min_titulars}" }
      Rails.logger.debug { "===group_ok? Total suplents in group #{groups[0]}: #{total_suplents} expected #{min_suplents}" }
      total_titulars == min_titulars && total_suplents == min_suplents
    end

    def num_votes_ok?(forms)
      Rails.logger.debug { "===candidats_ok? Total candidats #{get_candidats(forms).count} expected #{@question.max_votes - @question.min_votes}" }
      Rails.logger.debug { "===suplents_ok? Total suplents #{get_suplents(forms).count} expected #{@question.min_votes}" }
      suplents_ok?(forms) && candidats_ok?(forms)
    end

    def suplents_ok?(forms)
      get_suplents(forms).count == @question.min_votes
    end

    def candidats_ok?(forms)
      get_candidats(forms).count == @question.max_votes - @question.min_votes
    end

    def get_blancs(forms)
      forms.select do |f|
        f.response.blanc? locale
      end
    end

    def get_suplents(forms)
      forms.select do |f|
        f.response.suplent? locale
      end
    end

    def get_candidats(forms)
      forms.reject do |f|
        f.response.suplent? locale
      end
    end
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity:
