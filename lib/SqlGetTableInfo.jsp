<%@page import="java.sql.*"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page contentType="text/html; charset=utf-8" language="java"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap" %>
<%@page import="java.util.Set" %>
<%
// JDBC driver name and database URL
String JDBC_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";  
String DB_URL = "jdbc:sqlserver://example;databaseName=example;";

//  Database credentials
String USER = "EXAMPLE_USR";
String PASS = "EXAMPLE_PWS";

Connection conn = null;
PreparedStatement stmt = null;
try{
  
    String ReqCmd = request.getParameter( "Cmd" );
    String ReqFreeCmd = request.getParameter( "FreeCmd" );
    String ReqTableName = request.getParameter( "TableName" );
    String Cmd = "SELECT TABLE_NAME,COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS";
   
    // STEP 2: Register JDBC driver
    Class.forName(JDBC_DRIVER);

    // STEP 3: Open a connection    
    conn = DriverManager.getConnection(DB_URL, USER, PASS);
    stmt = conn.prepareStatement(Cmd);
    ResultSet rs = stmt.executeQuery();
    ResultSetMetaData rsmd = rs.getMetaData();
    int numColumns = rsmd.getColumnCount();

    JSONObject json = new JSONObject();
    Map<String, String> map = new HashMap();
    int j = 0;
    String DataTmp="";
    String ColName[] = new String[numColumns+1];    
    for (int i = 1; i < numColumns + 1; i++) {                         
        ColName[i] = rsmd.getColumnName(i);        
        map.put(String.valueOf(i),ColName[i]);
    }
    json.put("0",map);
    j=0; 
    int ColCounter=1;
    String dataTmp = "", FieldNames="";
    int TableCounter=1;
    map = new HashMap();
    while (rs.next()) {
        
        dataTmp = rs.getString(rsmd.getColumnName(1));
        
        if(map.get(dataTmp) != null){
            FieldNames += ", " + rs.getString(rsmd.getColumnName(2));
        }
        else{
            FieldNames = rs.getString(rsmd.getColumnName(2));
            TableCounter++;
        }
        map.put(dataTmp,FieldNames);
    
    }
    TableCounter=1;
    Map<String, String> Resultmap = new HashMap();
    Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();
    while (entries.hasNext()) {
        Resultmap = new HashMap();
        Map.Entry<String, String> entry = entries.next();
        // System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue());
        Resultmap.put("1",entry.getKey());
        Resultmap.put("2",entry.getValue());
        json.put(String.valueOf(TableCounter++),Resultmap);
    }

    
    out.println(json.toString());
    
}catch(SQLException se){
   //Handle errors for JDBC
   out.println("執行失敗!! SQLException"+se);
   se.printStackTrace();
}catch(Exception e){
   //Handle errors for Class.forName
   out.println("執行失敗!! Exception"+e);
   e.printStackTrace();
}finally{
   //finally block used to close resources
   try{
      if(stmt!=null)
         conn.close();
   }catch(SQLException se){
       se.printStackTrace();
   }
   try{
      if(conn!=null)
         conn.close();
   }catch(SQLException se){
      se.printStackTrace();
   }//end finally try
}
    %>
