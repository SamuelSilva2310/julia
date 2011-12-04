###########################################
# plotting functions
###########################################

# number of points to plot for functions
__PLOT_POINTS = 450

# the aspect ratio of plots
__PLOT_ASPECT_RATIO = 1.95

# how similar the domain and range needs to be for aspect ratio preservation
__PRESERVE_ASPECT_RATIO_THRESHOLD = 0.05

# how much extra padding to add around the plot
__HORIZONTAL_PADDING = 0.05
__VERTICAL_PADDING = 0.05

# plot an array (window determined manually)
function plot(x::Array, y::Array, xmin::Number, xmax::Number, ymin::Number, ymax::Number)
    # make sure we have arrays of numbers
    x_safe = try convert(Array{Float64, 1}, x[:]) catch return error("x coordinates must be convertable to float64") end
    y_safe = try convert(Array{Float64, 1}, y[:]) catch return error("y coordinates must be convertable to float64") end

    # make sure there are the same number of x and y coordinates
    if length(x_safe) != length(y_safe) return error("size of x and y arrays must be equal") end

    # make sure there are enough data to plot
    if length(x_safe) < 1 return error("at least two data points required for line plot") end

    # make sure the window is okay
    if xmin == Inf || xmin == -Inf || isequal(xmin, NaN) return error(strcat("invalid xmin: ", string(xmin))) end
    if xmax == Inf || xmax == -Inf || isequal(xmax, NaN) return error(strcat("invalid xmax: ", string(xmax))) end
    if ymin == Inf || ymin == -Inf || isequal(ymin, NaN) return error(strcat("invalid ymin: ", string(ymin))) end
    if ymax == Inf || ymax == -Inf || isequal(ymax, NaN) return error(strcat("invalid ymax: ", string(ymax))) end
    if xmin >= xmax return error("xmax must be greater than xmin") end
    if ymin >= ymax return error("ymax must be greater than ymin") end

    # JSON doesn't allow for +/-Inf or NaN
    for i=1:length(x_safe)
        if x_safe[i] == Inf || x_safe[i] == -Inf || isequal(x_safe[i], NaN) x_safe[i] = 0.0 end
        if y_safe[i] == Inf || y_safe[i] == -Inf || isequal(y_safe[i], NaN) y_safe[i] = 0.0 end
    end

    # send the message to the browser
    __write_message(__Message(__MSG_OUTPUT_PLOT, {
        "line",
        strcat("[", join([string(float64(i)) | i=x_safe], ","), "]"),
        strcat("[", join([string(float64(i)) | i=y_safe], ","), "]"),
        string(float64(xmin)),
        string(float64(xmax)),
        string(float64(ymin)),
        string(float64(ymax))
    }))
end

# plot an array (window determined automatically)
function plot(x::Array, y::Array)
    # make sure we have arrays of numbers
    x_safe = try convert(Array{Float64, 1}, x[:]) catch return error("x coordinates must be convertable to float64") end
    y_safe = try convert(Array{Float64, 1}, y[:]) catch return error("y coordinates must be convertable to float64") end

    # make sure there are the same number of x and y coordinates
    if length(x_safe) != length(y_safe) return error("size of x and y arrays must be equal") end

    # make sure there are enough data to plot
    if length(x_safe) < 1 return error("at least two data points required for line plot") end

    # JSON doesn't allow for +/-Inf or NaN
    for i=1:length(x_safe)
        if x_safe[i] == Inf || x_safe[i] == -Inf || isequal(x_safe[i], NaN) x_safe[i] = 0.0 end
        if y_safe[i] == Inf || y_safe[i] == -Inf || isequal(y_safe[i], NaN) y_safe[i] = 0.0 end
    end

    # determine the window
    xmin = min(x_safe)
    xmax = max(x_safe)
    ymin = min(y_safe)
    ymax = max(y_safe)
    if xmin == xmax
        xmin -= 0.5
        xmax += 0.5
    end
    if ymin == ymax
        ymin -= 0.5
        ymax += 0.5
    end

    # determine if we want to preserve the aspect ratio
    if abs((ymax-ymin)/(xmax-xmin)-1) < __PRESERVE_ASPECT_RATIO_THRESHOLD
        # we do -- determine the center of the plot
        cx = (xmax+xmin)/2.0
        cy = (ymax+ymin)/2.0

        # determine how big the window is
        w = max(xmax-xmin, ymax-ymin)/2.0
        wx = w+2.0*w*__HORIZONTAL_PADDING
        wy = w+2.0*w*__VERTICAL_PADDING

        # add some horizontal padding to preserve the aspect ratio
        plot(x_safe, y_safe, cx-wx*__PLOT_ASPECT_RATIO, cx+wx*__PLOT_ASPECT_RATIO, cy-wy, cy+wy)
    else
        # nope -- just add some padding
        plot(x_safe, y_safe,
            xmin-(xmax-xmin)*__HORIZONTAL_PADDING,
            xmax+(xmax-xmin)*__HORIZONTAL_PADDING,
            ymin-(ymax-ymin)*__VERTICAL_PADDING,
            ymax+(ymax-ymin)*__VERTICAL_PADDING)
    end
end

# plot an array (window determined automatically)
function plot(y::Array)
    # make sure we have an array of numbers
    y_safe = try convert(Array{Float64, 1}, y[:]) catch return error("y coordinates must be convertable to float64") end

    # make sure there are enough data to plot
    if length(y_safe) < 1 return error("at least two data points required for line plot") end

    # don't use +/-Inf or NaN when determining window
    for i=1:length(y_safe)
        if y_safe[i] == Inf || y_safe[i] == -Inf || isequal(y_safe[i], NaN)
            y_safe[i] = 0.0
        end
    end

    # determine the window
    x_safe = [i-1 | i=1:length(y_safe)]
    xmin = 0
    xmax = length(y)-1
    ymin = min(y_safe)
    ymax = max(y_safe)
    if ymin == ymax
        ymin -= 0.5
        ymax += 0.5
    end

    # determine if we want to preserve the aspect ratio
    if abs((ymax-ymin)/(xmax-xmin)-1) < __PRESERVE_ASPECT_RATIO_THRESHOLD
        # we do -- determine the center of the plot
        cx = (xmax+xmin)/2.0
        cy = (ymax+ymin)/2.0

        # determine how big the window is
        w = max(xmax-xmin, ymax-ymin)/2.0
        wx = w+2.0*w*__HORIZONTAL_PADDING
        wy = w+2.0*w*__VERTICAL_PADDING

        # add some horizontal padding to preserve the aspect ratio
        plot(x_safe, y_safe, cx-wx*__PLOT_ASPECT_RATIO, cx+wx*__PLOT_ASPECT_RATIO, cy-wy, cy+wy)
    else
        # nope -- just add some padding
        plot(x_safe, y_safe,
            xmin-(xmax-xmin)*__HORIZONTAL_PADDING,
            xmax+(xmax-xmin)*__HORIZONTAL_PADDING,
            ymin-(ymax-ymin)*__VERTICAL_PADDING,
            ymax+(ymax-ymin)*__VERTICAL_PADDING)
    end
end

# plot a function (vertical window determined automatically)
function plot(f::Function, xmin::Number, xmax::Number)
    # make the range
    x = [xmin+float64(i-1)*(xmax-xmin)/(__PLOT_POINTS-1) | i=1:__PLOT_POINTS]
    y = [try float64(f(i)) catch 0 end | i=x]

    # make the plot
    plot(x, y)
end

# plot a function (window determined manually)
function plot(f::Function, xmin::Number, xmax::Number, ymin::Number, ymax::Number)
    # make the range
    x = [xmin+float64(i-1)*(xmax-xmin)/(__PLOT_POINTS-1) | i=1:__PLOT_POINTS]
    y = [try float64(f(i)) catch 0 end | i=x]

    # make the plot
    plot(x, y, xmin, xmax, ymin, ymax)
end