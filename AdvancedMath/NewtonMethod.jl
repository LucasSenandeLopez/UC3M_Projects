using Plots
using Colors
using LaTeXStrings

function newton_solver(x₀::T, f::Function, f_prime::Function, ε::Number, loud = true) where {T <: Number}

    count::UInt128 = 0;

    xₙ::T = x₀;
    x_steps = [x₀];
    y_steps = [f(x₀)];
    errors = [abs(f(x₀))];

    while !(abs.(f(xₙ)) < ε);

        xₙ = xₙ - f(xₙ)/f_prime(xₙ); #Actualiza xₙ

        push!(x_steps, xₙ); #Inserta el nuevo valor de xₙ en un array para graficarlo
        push!(y_steps, f(xₙ));  #Inserta el nuevo valor de f(xₙ) en un array para graficarlo
        push!(errors, abs(f(xₙ))); #Inserta el error de la aproximación en el timestep n

        count += 1;

    end

    if loud
        println("Root of function $f approximated with a precision of $ε after $count iteration(s)")
    end

    return (xₙ, x_steps, y_steps, errors);

end

function convergence_test(f::Function, f_prime::Function, f_double_prime::Function, x₀::T) where {T <: Number}
    
    test = (f(x₀) * f_double_prime(x₀))/f_prime(x₀)^2

    return (abs(test) < convert(T, 1)) ? "Converge" : "Convergencia no asegurada";

end


f(x) = x^2 - 2;
f_prime(x) = 2*x;
f_double_prime(x) = 2;

x₀ = 2.0;

println(convergence_test(f, f_prime, f_double_prime, x₀), " En x₀ = $x₀");
println("\n√2 = ",newton_solver(2.0, f, f_prime, 1e-10, false)[1]);
println("√2 = ",newton_solver(-2.0, f, f_prime, 1e-10, false)[1],"\n");

const a = 2;
const b = 8;
x₀ = 1.0;

f(x) = x^b - cos(a*x);
f_prime(x) = b*x^(b-1) + a*sin(a*x);
f_double_prime(x) = b*(b-1)*x^(b-2) + (a^2)*cos(a*x);

println(convergence_test(f, f_prime, f_double_prime, x₀), " En x₀ = $x₀");
x, x_vec, y_vec, err_vec = newton_solver(1.0,f, f_prime, 1e-10);

pl = scatter(x_vec, y_vec, 
    color = colormap("Blues",length(x_vec)),
    label = false,
    background = :gray,
    xaxis = L"x",
    yaxis = L"f(x)");

xlims!(minimum(x_vec) - 0.5, maximum(x_vec) + 0.5)
ylims!(f(minimum(x_vec)) - 0.1, f(maximum(x_vec)) + 0.1)
plot!(f, 
    label = L"f(x) = x^%$b - cos(%$a x)",
    color = :red);

hline!([0], 
    label = false, 
    color = :blue);

vline!([x], 
    label = L"\hat x = %$x",
    color = :purple,
    linewidth = 2,
    alpha = 1);

vline!(x_vec[begin:end-1],
    label = false,
    color = :blue,
    linewidth = 1,
    alpha = 0.3);

title!(L"\mathrm{Aproximación\ por\ el\ método\ de\ Newton\ de\ }"
    * "\n" * L"f(x) = x^%$b - cos(%$a x) \mathrm{con\ } x_0 = %$x₀");


savefig(pl, "AdvancedMath/NewtonMethod.png");

pl_2 = plot(0:(length(err_vec) -1), err_vec, 
    label = L"\mathrm{Error\ de\ aproximación}",
    xaxis = L"\mathrm{Iteración}",
    yaxis = L"\mathrm{Error}",
    background = :gray,
    linewitdth = 3,
    color = :blue);

hline!([1e-10], 
    label = L"\mathrm{Precisión} = 1e-10",
    color = :red,
    linewidth = 3);

yaxis!(:log10);

savefig(pl_2, "AdvancedMath/NewtonMethodErrors.png");


f(x) = x^3 - 2*x^2 + x;
f_prime(x) = 3*x^2 - 4*x + 1;
f_double_prime(x) = 6*x - 4;

println(convergence_test(f, f_prime, f_double_prime, x₀), " En x₀ = 2.0");
println(convergence_test(f, f_prime, f_double_prime, x₀), " En x₀ = -2.0");


println("\nRaíz 1 de f = ",newton_solver(2.0, f, f_prime, 1e-10, false)[1]);
println("Raíz 2 de f = ",newton_solver(-2.0, f, f_prime, 1e-10, false)[1]);
