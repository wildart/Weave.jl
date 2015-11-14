import PLplot
import PLplot: plsdev, plsfnam, pageparams!, plend, plinit, plsfam, plgfam

const PLplotDevs = Dict(
        ".png" => "pngcairo",
        ".pdf" => "pdfcairo",
        ".ps"  => "pscairo",
        ".eps" => "epscairo",
        ".svg" => "svg"
    )

function init_plplot(chunk, report::Report)
    figpath = joinpath(report.cwd, chunk.options[:fig_path])
    isdir(figpath) || mkdir(figpath)
    chunkid = (chunk.options[:name] == nothing) ? chunk.number : chunk.options[:name]

    # Initialize device
    dev = PLplotDevs[chunk.options[:fig_ext]]
    plsdev(dev)

    # Set family parameters for generating multiple plot files
    plsfam(1, 1, 0)

    # set output file
    full_name, rel_name = get_figname(report, chunk)
    fn, fe = splitext(basename(full_name))
    plsfnam(joinpath(dirname(full_name), fn[1:end-1]*"%n"*fe))

    # set resolution
    w = chunk.options[:fig_width]
    h = chunk.options[:fig_height]
    dpi = chunk.options[:dpi]
    pageparams!(xdpi=dpi, ydpi=dpi, xlen=96w, ylen=96h)

    # initialize plot
    plinit()

    return
end

function close_plplot(chunk, report::Report)
    # get famity parameters to determine number of plots
    fam = Ref{Cint}()
    fnum = Ref{Cint}()
    pnum = Ref{Cint}()
    plgfam(fam, fnum, pnum)
    PLplot.plgpcnt(pnum)

    # switch page selection for images in multipage pdf files
    chunk.options[:fig_page] = pnum[] > 1 && chunk.options[:fig_ext] in [".pdf", ".ps"]

    # generate figure names
    fignames = AbstractString[]
    for n in 1:max(fnum[], pnum[])
        full_name, rel_name = chunk.options[:fig_page] ? get_figname(report, chunk) :
                                                         get_figname(report, chunk, fignum=n)
        push!(fignames, rel_name)
    end

    # close device
    plend()
    return fignames
end
