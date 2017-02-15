module FormHelpers
  def form_group(form, field, label, opts = {})
    FormGroupBuilder.form_group(form, field, label, opts)
  end

  def select_form_group(form, field, label, options)
    FormGroupBuilder.select_form_group(form, field, label, options)
  end

  class FormGroupBuilder
    def self.form_group(form, field, label, opts = {})
      input_type = opts.fetch(:input_type, "text")

      html = ""
      html += "<div class='form-group #{"has-error" if has_error?(form, field)}'>"
      html += "<label class='control-label' for='#{field}'>#{label}</label>"
      html += "<input type='#{input_type}' class='form-control' value='#{form.send(field)}' name='#{field}' id='#{field}'>"
      if has_error?(form, field)
        html += "<span class='help-block'>#{error_for(field)}</span>"
      end
      html += "</div>"
      html
    end

    def self.select_form_group(form, field, label, options)
      selected_attribute = ->(option){"selected" if form.send(field).to_s == option[:value].to_s}

      html = ""
      html += "<div class='form-group #{"has-error" if has_error?(form, field)}'>"
      html += "<label class='control-label' for='#{field}'>#{label}</label>"
      html += "<select class='form-control' name='#{field}' id='#{field}'>"
      html += options.map { |option| "<option #{selected_attribute.(option)} value='#{option[:value]}'>#{option[:text]}</option>" }.join
      html += "</select>"
      if has_error?(form, field)
        html += "<span class='help-block'>#{errors_for(field)}</span>"
      end
      html += "</div>"
      html
    end

    private

    def self.has_error?(form, field)
      !!error_for(form, field)
    end

    def self.error_for(form, field)
      return unless form.respond_to?(:errors)
      form.errors[field]
    end
  end
end
