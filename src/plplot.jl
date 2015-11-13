using PLplot: plsfnam, pageparams!, plend

const PLplotDevs = Dict(
        "png" => "pngcairo",
        "pdf" => "pdfcairo",
        "ps"  => "psc",
        "svg" => "svg"
    )

function init_plplot(chunk, report::Report)
    ext = report.formatdict[:fig_ext]
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkdir(figpath)
    chunkid = (chunk.options[:name] == nothing) ? chunk.number : chunk.options[:name]

    dev = PLplotDevs[chunk.options[:fig_ext]]
    full_name, rel_name = get_figname(report, chunk, fignum=fig)

    # Initialize device and set its parameters
    plsdev(dev)
    plsfnam(rel_name)
    pageparams!(xdpi=chunk.options[:dpi], ydpi=chunk.options[:dpi])

    return
end

function close_plplot(chunk, report::Report)
    fignames = AbstractString[]
    full_name, rel_name = get_figname(report, chunk, fignum=fig)
    push!(fignames, rel_name)
    plend()
    return fignames
end
