require 'tilt'
require 'tilt/erb'

class Showoff::Compiler
  require 'showoff/compiler/forms'
  require 'showoff/compiler/i18n'

  def initialize(options)
    @options = options
  end

  # Configures Tilt with the selected engine and options.
  #
  # Returns render options profile hash
  #
  # Source:
  #  https://github.com/puppetlabs/showoff/blob/3f43754c84f97be4284bb34f9bc7c42175d45226/lib/showoff_utils.rb#L671-L720
  # TODO: per slide profiles of render options
  def profile
    renderer = Showoff::Config.get('markdown')
    profile  = Showoff::Config.get(renderer)

    begin
      # Load markdown configuration
      case renderer
      when 'rdiscount'
        Tilt.prefer Tilt::RDiscountTemplate, "markdown"

      when 'maruku'
        Tilt.prefer Tilt::MarukuTemplate, "markdown"
        # Now check if we can go for latex mode
        require 'maruku'
        require 'maruku/ext/math'

        if profile[:use_tex]
          MaRuKu::Globals[:html_math_output_mathml] = false
          MaRuKu::Globals[:html_math_output_png]    = true
          MaRuKu::Globals[:html_math_engine]        = 'none'
          MaRuKu::Globals[:html_png_engine]         = 'blahtex'
          MaRuKu::Globals[:html_png_dir]            = profile[:png_dir]
          MaRuKu::Globals[:html_png_url]            = profile[:html_png_url]
        end

      when 'bluecloth'
        Tilt.prefer Tilt::BlueClothTemplate, "markdown"

      when 'kramdown'
        Tilt.prefer Tilt::KramdownTemplate, "markdown"

      when 'commonmarker', 'commonmark'
        Tilt.prefer Tilt::CommonMarkerTemplate, "markdown"

      else
        Tilt.prefer Tilt::RedcarpetTemplate, "markdown"

      end
    rescue LoadError
      puts "ERROR: The #{renderer} markdown rendering engine does not appear to be installed correctly."
      exit! 1
    end

    profile
  end

  def render(content)
    # add the real slide rendering logic here
    Tilt[:markdown].new(nil, nil, profile) { content }.render
  end

end