using TextWrap

#Format the executed document
function format(executed, doctype)
  formatted = String[]
  docformat = formats[doctype]
  #@show docformat

  #Complete format dictionaries with defaults
  formatdict = docformat.formatdict
  get!(formatdict, :termstart, formatdict[:codestart])
  get!(formatdict, :termend, formatdict[:codeend])
  get!(formatdict, :out_width, nothing)
  get!(formatdict, :out_height, nothing)
  get!(formatdict, :fig_pos, nothing)
  get!(formatdict, :fig_env, nothing)


  for chunk in copy(executed)

      if chunk[:type] == "doc"
          push!(formatted, chunk[:content])
      else
          #Fill undefined options with format specific defaults
          chunk[:out_width] == nothing && (chunk[:out_width] =  docformat.formatdict[:out_width])
          chunk[:fig_pos] == nothing && (chunk[:fig_pos] =  docformat.formatdict[:fig_pos])

          #Only use floats if chunk has caption or sets fig_env
          if chunk[:fig_cap] != nothing && chunk[:fig_env] == nothing
              (chunk[:fig_env] =  docformat.formatdict[:fig_env])
          end




          #Format code
          result = format_codechunk(chunk, formatdict)
          #Handle figures
          if chunk[:fig] && length(chunk[:figure]) > 0
              if chunk[:include]
                  result *= formatfigures(chunk, docformat)
              end
          end
          push!(formatted, result)
      end
  end

 return formatted
end


function format_codechunk(chunk, formatdict)
    if haskey(formatdict, :indent)
        chunk[:content] = indent(chunk[:content], formatdict[:indent])
    end

    if !chunk[:eval]
        if chunk[:echo]
            result = "$(formatdict[:codestart])$(chunk[:content])\n$(formatdict[:codeend])"
            return result
        else
            r = ""
            return r
        end
    end

    if chunk[:term]
        result = format_termchunk(chunk, formatdict)
    else
        if chunk[:wrap]
          chunk[:result] = "\n" * wrap(chunk[:result], replace_whitespace=false)
        end

        if chunk[:echo]
            result = "$(formatdict[:codestart])$(chunk[:content])\n$(formatdict[:codeend])\n"
        else
            result = ""
        end

        if (strip(chunk[:result])!= "") && (chunk[:results] != "hidden")
            #@show chunk
            if chunk[:results] != "markup"
                result *= "$(chunk[:result])"
            elseif chunk[:results] == "markup"
                if haskey(formatdict, :indent)
                    chunk[:result] = indent(chunk[:result], formatdict[:indent])
                end
                result *= "$(formatdict[:outputstart])$(chunk[:result])\n$(formatdict[:outputend])\n"
            end
        end

    end

    return result

end

function format_termchunk(chunk, formatdict)
    if chunk[:echo] && chunk[:results] != "hidden"
        result = "$(formatdict[:termstart])$(chunk[:result])\n"
        #@show chunk[:term_state]
        chunk[:term_state] == :text && (result*= "$(formatdict[:termend])\n")
    else
        result = ""
    end
    return result
end

function indent(text, nindent)
    return join(map(x->
                    string(repeat(" ", nindent), x), split(text, "\n")), "\n")
end


type Tex
    description::String
    formatdict::Dict{Symbol,Any}
end

const tex = Tex("Latex with custom code environments",
                @compat Dict{Symbol,Any}(:codestart => "\\begin{juliacode}",
                                         :codeend => "\\end{juliacode}",
                                         :outputstart => "\\begin{juliaout}",
                                         :outputend => "\\end{juliaout}",
                                         :termstart => "\\begin{juliaterm}",
                                         :termend => "\\end{juliaterm}",
                                         :fig_ext => ".pdf",
                                         :extension =>"tex",
                                         :out_width=> "\\linewidth",
                                         :fig_env=> "figure",
                                         :fig_pos => "htpb",
                                         :doctype => "tex"
                                         ))

const texminted = Tex("Latex using minted for highlighting",
                      @compat Dict{Symbol,Any}(
                                         :codestart => "\\begin{minted}[mathescape, fontsize=\\small, xleftmargin=0.5em]{julia}",
                                         :codeend => "\\end{minted}",
                                         :outputstart => "\\begin{minted}[fontsize=\\small, xleftmargin=0.5em, mathescape, frame = leftline]{text}",
                                         :outputend => "\\end{minted}",
                                         :termstart=> "\\begin{minted}[fontsize=\\footnotesize, xleftmargin=0.5em, mathescape]{julia}",
                                         :termend => "\\end{minted}",
                                         :fig_ext => ".pdf",
                                         :extension =>"tex",
                                         :out_width => "\\linewidth",
                                         :fig_env=> "figure",
                                         :fig_pos => "htpb",
                                         :doctype => "texminted"
                                         ))

type Markdown
    description::String
    formatdict::Dict{Symbol,Any}
end

const pandoc = Markdown("Pandoc markdown",
                        @compat Dict{Symbol,Any}(
                                :codestart => "~~~~{.julia}",
                                :codeend=>"~~~~~~~~~~~~~\n\n",
                                :outputstart=>"~~~~{.julia}",
                                :outputend=>"~~~~~~~~~~~~~\n\n",
                                :fig_ext=>".png",
                                :extension=>"md",
                                :doctype=>"pandoc"
                                               ))


const github = Markdown("Github markdown",
                        @compat Dict{Symbol,Any}(
                                :codestart => "````julia",
                                :codeend=> "````\n\n",
                                :outputstart=> "````julia",
                                :outputend=> "````\n\n",
                                :fig_ext=> ".png",
                                :extension=> "md",
                                :doctype=> "github"
                                               ))


type Rest
    description::String
    formatdict::Dict{Symbol,Any}
end

const rst = Rest("reStructuredText and Sphinx",
                 @compat Dict{Symbol,Any}(
                                :codestart => ".. code-block:: julia\n",
                                :codeend => "\n\n",
                                :outputstart => "::\n",
                                :outputend => "\n\n",
                                :indent=> 4,
                                :fig_ext => ".png",
                                :extension => "rst",
                                :out_width => "15 cm",
                                :doctype => "rst"
                                ))

type AsciiDoc
    description::String
    formatdict::Dict{Symbol,Any}
end

#asciidoc -b html5 -a source-highlighter=pygments ...
const adoc = AsciiDoc("AsciiDoc",
        @compat Dict{Symbol,Any}(
        :codestart => "[source,julia]\n--------------------------------------",
        :codeend => "--------------------------------------\n\n",
        :outputstart => "--------------------------------------",
        :outputend => "--------------------------------------\n\n",
        :fig_ext => ".png",
        :extension => "txt",
        :out_width => "600",
        :doctype => "asciidoc"
))


function formatfigures(chunk, docformat::Tex)
    fignames = chunk[:figure]
    caption = chunk[:fig_cap]
    width = chunk[:out_width]
    f_pos = chunk[:fig_pos]
    f_env = chunk[:fig_env]
    result = ""
    figstring = ""



    if f_env != nothing
        result *= """\\begin{$f_env}[$f_pos]\n"""
    end


    for fig = fignames
        figstring *= "\\includegraphics[width=$width]{$fig}\n"
    end

    # Figure environment
    if caption != nothing
        result *= string("\\center\n",
                         "$figstring",
                         "\\caption{$caption}\n")
    else
        result *= figstring
    end

    if chunk[:name] != nothing && f_env !=nothing
        label = chunk[:name]
        result *= "\\label{fig:$label}\n"
    end


    if f_env != nothing
        result *= "\\end{$f_env}\n"
    end

   return result
end

function formatfigures(chunk, docformat::Markdown)
    fignames = chunk[:figure]
    caption = chunk[:fig_cap]
    result = ""
    figstring = ""

    length(fignames) > 0 || (return "")

    if caption != nothing
        result *= "![$caption]($(fignames[1]))\n"
        for fig = fignames[2:end]
            result *= "![]($fig)\n"
            println("Warning, only the first figure gets a caption\n")
        end
    else
        for fig in fignames
            result *= "![]($fig)\n"
        end
    end
    return result
end


function formatfigures(chunk, docformat::Rest)
    fignames = chunk[:figure]
    caption = chunk[:fig_cap]
    width = chunk[:out_width]
    result = ""
    figstring = ""

    for fig=fignames
        figstring *= @sprintf(".. image:: %s\n   :width: %s\n\n", fig, width)
    end

    if caption != nothing
        result *= string(".. figure:: $(fignames[1])\n",
                         "   :width: $width\n\n",
                         "   $caption\n\n")
    else
        result *= figstring
        return result
    end
end


function formatfigures(chunk, docformat::AsciiDoc)
    fignames = chunk[:figure]
    caption = chunk[:fig_cap]
    width = chunk[:out_width]
    result = ""
    figstring = ""


    for fig=fignames
        figstring *= @sprintf("image::%s[width=%s]\n", fig, width)
    end


    if caption != nothing
        result *= string("image::$(fignames[1])",
        "[width=$width,",
        "title=\"$caption\"]")
    else
        result *= figstring
        return result
    end
end


#Add new supported formats here
const formats = @compat Dict{String, Any}("tex" => tex,
                                          "texminted" => texminted,
                                          "pandoc" => pandoc,
                                          "github" => github,
                                          "rst" => rst,
                                          "asciidoc" => adoc
                                          )
