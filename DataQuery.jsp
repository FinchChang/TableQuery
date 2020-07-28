<%@page import="java.sql.*"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>

<%@ page contentType="text/html; charset=utf-8" language="java"%>
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
<title>Execute SQL Cmd</title>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.4.4/cjs/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script>
</head>


<body>
<div class="container">
<div class="row">

    <form id="CmdForm">
        <div class="col">
            <div class="input-group-prepend">
                <span class="input-group-text">SELECT</span>
            </div>
            <input class="form-control" id="FieldName" name="FieldName" type="text" />
        <div class="input-group-prepend">
            <span class="input-group-text">FROM</span>
        </div>
        <input class="form-control" id="TableName" type="text" name="TableName" list="TableList">
        <datalist id="TableList">
        </datalist>
            <input id="SelectSubmit" class="btn btn-primary" type="submit" value="查詢" />
        </div>
    </form>
</div>
<p>
    <div class="input-group-prepend">
        <span class="input-group-text">Search(English Only)</span>
    </div>
    <input class="form-control" id="search" type="search" onkeyup="filterTable()" aria-label="Default" aria-describedby="inputGroup-sizing-default">
</p>
<!--
<div class="row">
    <form action="executeSqlCmd.jsp" method="post">
        <div class="input-group">
            <input type="text" class="form-control" name="FreeCmd" id="FreeCmd" placeholder="自由輸入command" aria-label="自由輸入command" aria-describedby="button-addon2">
            <div class="input-group-append">
                <input class="btn btn-outline-secondary" type="submit" id="button-addon2" value="查詢">
            </div>
        </div>
    </form>
</div>
-->
    <script>
        var colArray = [];  
    </script>
    <div id="DataRegoin" class="row">

    </div>
</div>
<script>
$( document ).ready(function() {
    $.ajax({url: "lib/SqlGetTableInfo.jsp", success: function(result){
        var Json_TableInfo = JSON.parse(result);
        var propCount = Object.keys(Json_TableInfo).length;
        Json2Table(Json_TableInfo , 1);
        let TableNameTmp = [];
        for(var k in Json_TableInfo) {
            if(Json_TableInfo[k][1] == "TABLE_NAME"){
                continue;
            }
            if(TableNameTmp != Json_TableInfo[k][1]){
                TableNameTmp = Json_TableInfo[k][1];
                $("#TableList").append($("<option>").attr('value', Json_TableInfo[k][1]));
            }            
        }
    }});
    
    
});
$("#CmdForm").submit(function(e) {
    e.preventDefault(); // avoid to execute the actual submit of the form.
    var form = $(this);
    
    $.ajax({
        type: "POST",
        url: "lib/SqlCmdAjax.jsp",        
        data: {"TableName":$('#TableName').val(),"FieldName":$('#FieldName').val()},
        success: function (msg) {
            var CmdResult = JSON.parse(msg);
            $('#DataTable').remove();
            Json2Table(CmdResult, 0);
            },
            statusCode: {
                403: function (response) {
                    LocationHerf();
                }
            }       
    });
});


function Json2Table(Json, DataInfo){
    let Title = [], TitleCounter=0;;
    let Datatmp = "<table id='DataTable' class='table table-striped table-bordered table-dark'><thead><tr>";
    for(var k in Json) {
        if(0 == k){
            Datatmp += "<th>"+k+"</th>";
            for(var l in Json[k]) {            
                Title[TitleCounter++]=Json[k][l];
                Datatmp += "<th>"+ Json[k][l] + "</th>";
            }
            Datatmp +="</tr></thead><tbody>";
        }
        else{
            const mapTmp = Json[k];
            Datatmp += "<tr><td>"+k+"</td>";
            if(DataInfo){
                for(var l in Json[k]) {
                Datatmp +=  "<td>" + Json[k][l] + "</td>";  
            }
            }else{                
                const dataList = new Map(Object.entries(Json[k]));
                
                for(var t in Title){
                    let getData = dataList.get(Title[t]);
                    Datatmp +=  "<td>" + getData + "</td>";  
                }
                
            }
            
            
            
        }
        Datatmp +="</tr>";
    }
     Datatmp += "</tbody></table>"
     $('#DataRegoin').append(Datatmp);        
}



function filterTable() {
  var input, filter, table, tr, td, i, txtValue, idx, j, oriStr, FindData;
  input = document.getElementById("search");
  filter = input.value.toUpperCase();
  table = document.getElementById("DataTable");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    FindData = 0;
    for(j = 0 ; j < tr[i].cells.length ; j++){
        td = tr[i].getElementsByTagName("td")[j];
        if (td) {
          td.textContent = td.textContent.replace("<span style='color:red;'>","");
          td.textContent = td.textContent.replace("</span>","");
          txtValue = td.textContent || td.innerText;
          idx = txtValue.toUpperCase().indexOf(filter);
          oriStr = txtValue.substr(idx,input.value.length);
          if (idx > -1) {
            FindData = 1;
            td.innerHTML = td.innerHTML.replace(oriStr,"<span style='color:red;'>" + oriStr + "</span>");
            tr[i].style.display = "";
          } else {
            if(FindData){
                tr[i].style.display = "";
            }
            else{
                tr[i].style.display = "none";
            }
            
          }
        }
    }
      
  }
}


</script>
</body>
</html>
