Option Explicit

Sub passData()

    Dim company As Integer
    Dim year As Integer
    Dim field As Integer
    Dim Val As Variant
    Dim sheetName As String
    Dim fieldNames() As Variant
    Dim numFields As Integer
    
    fieldNames = Array("Assets (th USD)", "BVE", "NI", "MarketCap", "RoE", _
        "RoA", "Price", "EnterpriseValue", _
        "CommonSharesOutstanding", "Cash", "EBIT", "InterestExpense", "Sales", "D&A")
        
    numFields = UBound(fieldNames) - LBound(fieldNames)
   
    
    sheetName = "Results"
    
    If Sheets.Count = 2 Then
    
        For company = 1 To 5
            
            Sheets.Add , After:=Sheets(Sheets.Count)
            
            sheetName = Application.Worksheets("Results").Cells(company + 1, 2).Value
            
            ActiveSheet.Name = sheetName
        
            Worksheets("Results").Activate
        
        Next
        
    End If


    For field = 0 To numFields

        For company = 1 To 5
        
            For year = 1 To 10
            
                Val = Sheets(2).Cells(company + 1, 10 * field + 2 + year).Value
                
                If ((field = 4) Or (field = 5)) And Not (Val = "n.a.") Then Val = Val / 100
                If (field = 8) And Not (Val = "n.a.") Then Val = Val * 1000

                Sheets(company + 2).Cells(year + 1, field + 2).Value = Val ' Introduce el valor en la celda correspondiente
             
            Next
            
        
        Next

    Next
    
    For company = 1 To 5
    
        Sheets(company + 2).Select
    
        For year = 2014 To 2023
        
            Cells(year - 2012, 1).Value = year          
            
            ' Market Value of Debt
            Cells(year - 2012, numFields + 3).Value = Cells(year - 2012, 9).Value + Cells(year - 2012, 11).Value - Cells(year - 2012, 5).Value
            
            ' Common Shares outstanding if missing
            If Cells(year - 2012, 10).Value = "n.a." Then Cells(year - 2012, 10).Value = _
                Round(Cells(year - 2012, 5).Value / Cells(year - 2012, 8).Value)
    
            ' ICR
            Cells(year - 2012, numFields + 4).Value = Cells(year - 2012, 12).Value / Cells(year - 2012, 13).Value 
        Next
        
        For field = 0 To numFields
        
            ' Because of zero indexing, we have to sum one so it doesn't go out of range and 2 so it does not fill the year column
            Cells(1, field + 2) = fieldNames(field)
            
        Next
            
            Cells(1, 1).Value = "Year"
            Cells(1, numFields + 3) = "D" ' Places the Debt header
            Cells(1, numFields + 4) = "ICR"
            Sheets(company + 2).Columns.AutoFit
    
    Next

End Sub
