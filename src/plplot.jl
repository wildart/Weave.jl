import PLplot

"""Pre-execute hooks to set the plot size for the chunk """
function plots_set_size(chunk)
  w = chunk.options[:fig_width] * chunk.options[:dpi]
  h = chunk.options[:fig_height] * chunk.options[:dpi]
  PLplot.set_default_plot_size(w,h)
  return chunk
end

push_preexecute_hook(plots_set_size)

"""Add saved figure name to results and return the name"""
function add_plots_figure(report::Report, plot::PLplot.Plot, ext)
  chunk = report.cur_chunk
  full_name, rel_name = get_figname(report, chunk, ext = ext)

  open(full_name, "w") do io
    write(io, plot.blob)
  end
  push!(report.figures, rel_name)
  report.fignum += 1
  return full_name
end

function Base.display(report::Report, m::MIME"application/pdf", plot::PLplot.Plot{PLplot.PDF})
    add_plots_figure(report, plot, ".pdf")
end

function Base.display(report::Report, m::MIME"image/png", plot::PLplot.Plot{PLplot.PNG})
    add_plots_figure(report, plot, ".png")
end

function Base.display(report::Report, m::MIME"image/svg+xml", plot::PLplot.Plot{PLplot.SVG})
    add_plots_figure(report, plot, ".svg")
end
