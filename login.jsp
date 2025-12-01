<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if("POST".equalsIgnoreCase(request.getMethod())){
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String redirect = request.getParameter("redirect");

    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
        ps.setString(1,username);
        ps.setString(2,password);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            session.setAttribute("user", username);
            session.setAttribute("role", rs.getString("role"));
            if(redirect!=null && !redirect.isEmpty()){
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect("index.jsp");
            }
        } else {
            out.print("<p style='color:red'>Wrong username or password</p>");
        }
        con.close();
    } catch(Exception e){ out.print(e); }
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2>Login</h2>
    <form method="post">
        <input type="text" name="username" placeholder="Username" required><br>
        <input type="password" name="password" placeholder="Password" required><br>
        <input type="hidden" name="redirect" value="<%= request.getParameter("redirect") %>">
        <input type="submit" value="Login">
    </form>
    <p>New user? <a href="register.jsp">Register here</a></p>
</div>
</body>
</html>