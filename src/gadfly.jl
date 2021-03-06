using Gadfly

Gadfly.set_default_plot_format(:png)

#Captures figures
function Base.display(report::Report, m::MIME"image/png", p::Plot)
    chunk = report.cur_chunk

    full_name, rel_name = get_figname(report, chunk)

    docformat = formats[report.formatdict[:doctype]]

    #Add to results for term chunks and store otherwise
    if chunk[:term]
      chunk[:figure] = [rel_name]

      if report.term_state == :text
        report.cur_result *= "\n" * report.formatdict[:codeend] * "\n"
      end


      report.cur_result *= formatfigures(chunk, docformat)
      report.term_state = :fig
      chunk[:figure] = String[]
    else
      push!(report.figures, rel_name)
    end

    report.fignum += 1

    w = chunk[:fig_width]inch
    h = chunk[:fig_height]inch
    format = chunk[:fig_ext]
    dpi = chunk[:dpi]

    #This is probably not the correct way to handle different formats, but it works.
    if format == ".png"
        try
          draw(PNG(full_name, w, h, dpi=dpi), p)
        catch
          draw(PNG(full_name, w, h), p) #Compose < 0.3.1, Gadfly < 0.3.1
        end
    elseif format == ".pdf"
        draw(PDF(full_name, w, h), p)
    elseif format == ".ps"
        draw(PS(full_name, w, h), p)
    elseif format == ".svg"
        draw(SVG(full_name, w, h), p)
    elseif format == ".js.svg"
        draw(SVGJS(full_name, w, h), p)
    else:
        warn("Can't save figure. Unsupported format")
    end
end
