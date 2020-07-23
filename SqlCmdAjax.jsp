<%@page import="java.sql.*"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap" %>
<%!
public String pMemo(String input){
	//return some memo for phone
	return ""
}
%>
<%
// JDBC driver name and database URL
String JDBC_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";  
String DB_URL = "jdbc:sqlserver://example;databaseName=example;";

//  Database credentials
String USER = "example_user";
String PASS = "example_pwd";

Connection conn = null;
PreparedStatement stmt = null;
try{
  
    String ReqFieldName = request.getParameter( "FieldName" );
    String ReqFreeCmd = request.getParameter( "FreeCmd" );
    String ReqTableName = request.getParameter( "TableName" );
    String Cmd = ""; 
    //System.out.println("Cmd=SELECT "+ReqFieldName + " FROM " + ReqTableName);

    // STEP 2: Register JDBC driver
    Class.forName(JDBC_DRIVER);

    // STEP 3: Open a connection    
    conn = DriverManager.getConnection(DB_URL, USER, PASS);
    
    String getTable = "SELECT name FROM SYSOBJECTS WHERE xtype = 'U'";    
    String DataTmp = "";

    int j = 0;
    int ColCounter=0, numColumns=0;
               
    if((ReqFieldName != null) && (!"".equals(ReqFieldName)))  {
        Cmd = "SELECT " + ReqFieldName.trim() + " FROM " + ReqTableName;                
    }    
    if((ReqFreeCmd != null ) && (!"".equals(ReqFreeCmd))){
        Cmd = ReqFreeCmd.trim();
    }
    
    //System.out.println("Final Cmd = " + Cmd);
    
    JSONObject json = new JSONObject();
    Map<String, String> map = new HashMap();
    if((Cmd != null) && (!"".equals(Cmd))){
        // out.println("Cmd  = " + Cmd + "<br>");
        // STEP 4: Execute a query        
        stmt = conn.prepareStatement(Cmd);
        ResultSet rs = stmt.executeQuery();
  
        if(rs != null){
            ResultSetMetaData rsmd = rs.getMetaData();
            numColumns = rsmd.getColumnCount();
            int idx_cp=-1;
            String ColumnNameTmp="";
            String ColName[] = new String[numColumns+1];
            for (int i = 1; i < numColumns + 1; i++) {                 
                ColName[i] = rsmd.getColumnName(i);
                // out.println("<th scope='col'>"+ColumnNameTmp+"</th>");
                if("cp".equals(ColumnNameTmp)){
                    idx_cp = i;
                }
                map.put(String.valueOf(i),ColName[i]);
            }
            json.put("0",map);
            j=0; 
            ColCounter=1;
            String dataTmp = "", phoneName="";       
            while (rs.next()) {
                map = new HashMap();
                for (j = 1; j < numColumns + 1; j++) {
                    dataTmp = rs.getString(rsmd.getColumnName(j));
                    if(idx_cp == j){
                        dataTmp= dataTmp+pMemo(dataTmp);
                    }
                    map.put(ColName[j],dataTmp);                    
                }
                json.put(ColCounter++,map);
            }
        }
    }
    else{

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
