function genTable(titulos::Vector{String}, matriz::Matrix{Any},latex::Int = 0)

    # Verifica que el número de columnas coincida con los títulos
    @assert size(matriz, 1) == length(titulos) "El número de Filas de la matriz debe coincidir con los títulos"
    
    # Crea el DataFrame columna por columna
    df = DataFrame()
    for (i, titulo) in enumerate(titulos)
        df[!, Symbol(titulo)] = matriz[i,:]
    end
    pretty_table(df, column_labels = names(df), maximum_number_of_rows = -1)
    if latex == 1
        pretty_table(Matrix(df), backend = :latex,column_labels = names(df) , maximum_number_of_rows = -1)
    end
    
end

