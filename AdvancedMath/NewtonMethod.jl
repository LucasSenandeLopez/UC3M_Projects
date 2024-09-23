using Plots
using Colors
using LaTeXStrings

function newton_solver(x₀::T, f::Function, f_prime::Function, ε::Real, loud = true, limit::Int64 = 100_000) where {T <: Number}
"""
Aproxima mediante el método de Newton la función dada por el parámetro f hasta que 
ocurra uno de los dos casos:
    1. f(xₙ) se encuentre en el rango de precisión establecido.
    2. Se sobrepase el número máximo de iteraciones estabelcido.
---------------------------- Argumentos ----------------------------
La función toma como argumentos:
    Obligatorios:
        x₀ (Número): El valor inicial con el que se comenzará la secuencia recursiva.
        f (Función): La función a aproximar.
        f_prime (Función): Función derivada de la función a aproximar `f`.
        ε (Número real): Precisión requerida en la aproximación. La iteración se detiene una vez el valor absoluto de
            la función en una iteración sea menor a este argumento.
    
    Opcionales:
        loud (Booleano): Un valor de true envía un mensaje a la consola tras acabar la iteración. True por defecto.
        limit (Número entero nonegativo): Número máximo de iteraciones. 100 000 por defecto.

---------------------------- Devuelve ----------------------------
    xₙ (Número): Aproximación de la raíz.
    x_steps (Vector de Números): Secuencia entera de {xₙ}.
    y_steps (Vector de Números): Secuencia entera de {f(xₙ)}.
    errors (Vector de Números reales): Secuencia de {|f(xₙ)|}.
"""
    @assert limit >= 0 "El argumento \"limit\" debe ser un entero nonegativo."
    count::Int64 = 0;
    i::Int64 = 2;

    xₙ::T = x₀;
    x_steps = Vector{T}(undef, limit + 1);
    y_steps = Vector{T}(undef, limit + 1);
    errors = Vector{T}(undef, limit + 1);

    x_steps[begin] = x₀;
    y_steps[begin] = f(x₀);
    errors[begin] = abs(f(x₀));

    @inbounds while !(abs.(f(xₙ)) < ε) && i <= limit + 1;

        xₙ = xₙ - f(xₙ)/f_prime(xₙ); #Actualiza xₙ

        x_steps[i] = xₙ; #Inserta el nuevo valor de xₙ en un array para graficarlo
        y_steps[i] = f(xₙ);  #Inserta el nuevo valor de f(xₙ) en un array para graficarlo
        errors[i] = abs(f(xₙ)); #Inserta el error de la aproximación en el timestep n

        count += 1;
        i += 1;

    end

    if loud
        println("Raíz de la función $f aproximada con una precisión de $ε tras $count iteracion(es)");
    end

    resize!(x_steps, count + 1);
    resize!(y_steps, count + 1);
    resize!(errors, count + 1);

    return (xₙ, x_steps, y_steps, errors);

end

function convergence_test(f::Function, f_prime::Function, f_double_prime::Function, x₀::T) where {T <: Number}
"""
Realiza el test de convergencia del método de Newton con un valor inicial determinado.

---------------------------- Argumentos ----------------------------
    x₀ (Número): El valor inicial con el que se comenzará la secuencia recursiva.
    f (Función): La función a aproximar.
    f_prime (Función): Función derivada de la función a aproximar `f`.
    f_double_prime (Función): Función derivada segunda de la función a aproximar `f`.

---------------------------- Devuelve ----------------------------
    (String): Cadena de carácteres que sugiere la convergencia del método al empezar en x₀.
"""

    test = (f(x₀) * f_double_prime(x₀))/f_prime(x₀)^2;

    return (abs(test) < convert(T, 1)) ? "Converge" : "Convergencia no asegurada";

end

println("------------------------------- Resultados -------------------------------");
#=
Se valida el método calculando √2.
=#

f(x) = x^2 - 2;
f_prime(x) = 2*x;
f_double_prime(x) = 2;

x₀ = 2.0;

println("x^2 - 2 ",convergence_test(f, f_prime, f_double_prime, x₀), " con x₀ = $x₀");

println("\n√2 = ",newton_solver(2.0, f, f_prime, 1e-10, false)[1]);
println("√2 = ",newton_solver(-2.0, f, f_prime, 1e-10, false)[1],"\n");

#=
Se realiza la aproximación principal.
=#

const a = 2;
const b = 8;
x₀ = 1.0;
ε = 1e-15;

f(x) = x^b - cos(a*x);
f_prime(x) = b*x^(b-1) + a*sin(a*x);
f_double_prime(x) = b*(b-1)*x^(b-2) + (a^2)*cos(a*x);

println("x^$b - cos($a x) ",convergence_test(f, f_prime, f_double_prime, x₀), " con x₀ = $x₀");
x, x_vec, y_vec, err_vec = newton_solver(x₀,f, f_prime, ε);

println("f'(̂x) = $(round(f_prime(x), digits=2))");
println("f''(̂x) = $(round(f_double_prime(x), digits=2))");


#=
Se grafican los resultados de la aproximación.
=#

pl = scatter(x_vec, y_vec, 
    color = colormap("Blues",length(x_vec)),
    label = false,
    background = :gray,
    xaxis = L"x",
    yaxis = L"f(x)");

xlims!(minimum(x_vec) - 0.5, maximum(x_vec) + 0.5);
ylims!(minimum(y_vec) - 0.1, maximum(y_vec) + 0.1);
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
    * "\n" * L"f(x) = x^%$b - cos(%$a x) \mathrm{\ con\ } x_0 = %$x₀");


savefig(pl, "AdvancedMath/NewtonMethod.png");


#=
Se grafican los errores de la aproximación.
=#

pl_2 = plot(0:(length(err_vec)-1), err_vec, 
    label = L"\mathrm{Error\ de\ aproximación}",
    xaxis = L"\mathrm{Iteración}",
    yaxis = L"\mathrm{Error}",
    background = :gray,
    linewitdth = 3,
    color = :blue);

hline!([ε], 
    label = L"\mathrm{Precisión} = %$ε",
    color = :red,
    linewidth = 3);

yaxis!(:log10);
title!(L"\mathrm{Errores\ de\ aproximación\ del\ método\ de\ Newton\ para\ }" * "\n" * 
    L"f(x) = x^%$b - cos(%$a x)");

savefig(pl_2, "AdvancedMath/NewtonMethodErrors.png");

#=
Se prueba el método al calcular dos raíces de otra función.
=#

f(x) = x^3 - 2*x^2 + x;
f_prime(x) = 3*x^2 - 4*x + 1;
f_double_prime(x) = 6*x - 4;

println("\n\n",convergence_test(f, f_prime, f_double_prime, x₀), " en x₀ = 2.0");
println(convergence_test(f, f_prime, f_double_prime, x₀), " en x₀ = -2.0");

x, x_vec, y_vec, err_vec = newton_solver(2.0, f, f_prime, ε, false)

println("\nRaíz 1 de f = ",x);
println("f'(̂x) = $(round(f_prime(x), digits=2))");
println("f''(̂x) = $(round(f_double_prime(x), digits=2))");
#=
Se grafica el método para la primera raíz de f(x)
=#
pl_f2_1_1 = scatter(x_vec, y_vec, 
    color = colormap("Blues",length(x_vec)),
    label = false,
    background = :gray,
    xaxis = L"x",
    yaxis = L"f(x)");

xlims!(minimum(x_vec) - 0.5, maximum(x_vec) + 0.5);
ylims!(f(minimum(x_vec)) - 0.1, f(maximum(x_vec)) + 0.1);
plot!(f, 
    label = L"f(x) = x^3 - 2x^2 + x",
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
    * "\n" * L"f(x) = x^3 - 2x^2 + x \mathrm{\ con\ } x_0 = 2.0");

# f2r1 hace referencia a que es la primera raíz (r1) de la función dos (f2).
savefig(pl_f2_1_1, "AdvancedMath/NewtonMethodf2r1.png");

pl_f2_1_2 = plot(0:(length(err_vec) -1), err_vec, 
    label = L"\mathrm{Error\ de\ aproximación}",
    xaxis = L"\mathrm{Iteración}",
    yaxis = L"\mathrm{Error}",
    background = :gray,
    linewitdth = 3,
    color = :blue);

hline!([ε], 
    label = L"\mathrm{Precisión} = %$ε",
    color = :red,
    linewidth = 3);

yaxis!(:log10);

title!(L"\mathrm{Errores\ de\ aproximación\ del\ método\ de\ Newton\ para\ }" *
    "\n" * L"f(x) = x^3 - 2x^2 + x");

savefig(pl_f2_1_2, "AdvancedMath/NewtonMethodErrorsf2r1.png");




#=
Se grafica el método para la segunda raíz de f(x).
=#
x, x_vec, y_vec, err_vec = newton_solver(-2.0, f, f_prime, ε, false);
println("Raíz 2 de f = ",x);

println("f'(̂x) = $(round(f_prime(x), digits=2))");
println("f''(̂x) = $(round(f_double_prime(x), digits=2))");



pl_f2_2_1 = scatter(x_vec, y_vec, 
    color = colormap("Blues",length(x_vec)),
    label = false,
    background = :gray,
    xaxis = L"x",
    yaxis = L"f(x)");

xlims!(minimum(x_vec) - 0.5, maximum(x_vec) + 0.5);
ylims!(f(minimum(x_vec)) - 0.1, f(maximum(x_vec)) + 0.1);
plot!(f, 
    label = L"f(x) = x^3 - 2x^2 + x",
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
    * "\n" * L"f(x) = x^3 - 2x^2 + x \mathrm{\ con\ } x_0 = -2.0");

# f2r1 hace referencia a que es la segunda raíz (r2) de la función dos (f2).
savefig(pl_f2_2_1, "AdvancedMath/NewtonMethodf2r2.png");

pl_f2_2_2 = plot(0:(length(err_vec) -1), err_vec, 
    label = L"\mathrm{Error\ de\ aproximación}",
    xaxis = L"\mathrm{Iteración}",
    yaxis = L"\mathrm{Error}",
    background = :gray,
    linewitdth = 3,
    color = :blue);

hline!([ε], 
    label = L"\mathrm{Precisión} = %$ε",
    color = :red,
    linewidth = 3);

yaxis!(:log10);
title!(L"\mathrm{Errores\ de\ aproximación\ del\ método\ de\ Newton\ para\ }" 
    *"\n" * L"f(x) = x^3 - 2x^2 + x");

savefig(pl_f2_2_2, "AdvancedMath/NewtonMethodErrorsf2r2.png");
println("--------------------------------------------------------------------------");