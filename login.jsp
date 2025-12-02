<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String error = "";
    String redirect = request.getParameter("redirect");

    if("POST".equalsIgnoreCase(request.getMethod())){
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");
            PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                session.setAttribute("user", username);
                session.setAttribute("role", rs.getString("role"));

                if(redirect != null && !redirect.isEmpty()){
                    response.sendRedirect(redirect);
                } else {
                    response.sendRedirect("index.jsp");
                }
                return;
            } else {
                error = "Wrong username or password!";
            }
            con.close();
        } catch(Exception e){
            error = "Login failed. Please try again.";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login • Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            
            /* BEAUTIFUL HOTEL BACKGROUND */
            background: linear-gradient(rgba(0, 0, 0, 0.65), rgba(0, 0, 0, 0.7)),
                        url('https://images.unsplash.com/photo-1611892441792-ae6af465f15c?ixlib=rb-4.0.3&auto=format&fit=crop&q=80') center/cover no-repeat fixed;
            color: white;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            width: 100%;
            max-width: 480px;
            border-radius: 24px;
            padding: 45px 40px;
            box-shadow: 0 30px 80px rgba(0, 0, 0, 0.4);
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .logo {
            font-size: 42px;
            font-weight: 800;
            color: #1e40af;
            margin-bottom: 8px;
            text-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .tagline {
            color: #475569;
            margin-bottom: 30px;
            font-size: 17px;
            font-weight: 500;
        }
        h2 {
            color: #1e40af;
            margin-bottom: 30px;
            font-size: 30px;
            font-weight: 700;
        }
        .form-group {
            margin-bottom: 22px;
            text-align: left;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #374151;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 16px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 14px;
            font-size: 16px;
            transition: all 0.3s;
            background: white;
        }
        input:focus {
            outline: none;
            border-color: #f59e0b;
            box-shadow: 0 0 0 5px rgba(251, 146, 60, 0.25);
            transform: scale(1.02);
        }
        .error {
            background: #fee2e2;
            color: #dc2626;
            padding: 14px;
            border-radius: 12px;
            margin: 15px 0;
            font-weight: 500;
            border-left: 5px solid #dc2626;
        }
        .login-btn {
            width: 100%;
            padding: 18px;
            background: #f59e0b;
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 19px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
            box-shadow: 0 10px 25px rgba(251, 146, 60, 0.4);
        }
        .login-btn:hover {
            background: #ea8c00;
            transform: translateY(-4px);
            box-shadow: 0 15px 30px rgba(251, 146, 60, 0.5);
        }
        .footer-text {
            margin-top: 30px;
            color: #64748b;
            font-size: 15.5px;
            font-weight: 500;
        }
        .footer-text a {
            color: #1e40af;
            font-weight: 700;
            text-decoration: none;
        }
        .footer-text a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="login-card">
    <div class="logo">Booking</div>
    <p class="tagline">Welcome back! Please login to continue</p>

    <h2>Login</h2>

    <% if(!error.isEmpty()){ %>
        <div class="error"><%= error %></div>
    <% } %>

    <form method="post">
        <input type="hidden" name="redirect" value="<%= redirect != null ? redirect : "" %>">

        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username" required autofocus>
        </div>

        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Enter your password" required>
        </div>

        <button type="submit" class="login-btn">Login to Booking</button>
    </form>

    <div class="footer-text">
        New to Booking? <a href="register.jsp">Create an account</a>
    </div>
</div>

</body>
</html>