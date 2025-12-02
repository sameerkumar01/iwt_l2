<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String message = "";
    if ("POST".equals(request.getMethod())) {
        try {
            int hotel_id = Integer.parseInt(request.getParameter("hotel_id"));
            String type = request.getParameter("type");
            double price = Double.parseDouble(request.getParameter("price"));

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO rooms (hotel_id, type, price, available) VALUES (?, ?, ?, true)"
            );
            ps.setInt(1, hotel_id);
            ps.setString(2, type);
            ps.setDouble(3, price);
            ps.executeUpdate();
            con.close();

            message = "<div style='background:#d4edda;color:#155724;padding:16px;border-radius:12px;margin:20px 0;text-align:center;font-weight:bold;border-left:5px solid #28a745;'>Room added successfully!</div>";
        } catch (Exception e) {
            message = "<div style='background:#f8d7da;color:#721c24;padding:16px;border-radius:12px;margin:20px 0;text-align:center;border-left:5px solid #dc3545;'>Error: " + e.getMessage() + "</div>";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Room • Booking Admin</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5f7fa;color:#333;}
        header{
            background:#003580;color:white;padding:20px 40px;
            display:flex;justify-content:space-between;align-items:center;
            box-shadow:0 4px 10px rgba(0,0,0,0.1);
        }
        .logo{font-size:28px;font-weight:bold;}
        .user-info a{color:white;margin-left:25px;text-decoration:none;font-weight:500;}
        .user-info a:hover{text-decoration:underline;}

        .container{max-width:800px;margin:40px auto;padding:0 20px;}
        .page-title{
            text-align:center;font-size:36px;color:#003580;margin:20px 0 10px;
        }
        .subtitle{
            text-align:center;color:#666;font-size:18px;margin-bottom:40px;
        }

        .form-card{
            background:white;border-radius:16px;padding:40px;
            box-shadow:0 12px 35px rgba(0,0,0,0.1);
            max-width:650px;margin:0 auto;
        }
        .form-group{
            margin-bottom:25px;
        }
        label{
            display:block;font-weight:600;color:#003580;margin-bottom:10px;font-size:17px;
        }
        select, input[type="text"]{
            width:100%;padding:16px 18px;border:2px solid #ddd;
            border-radius:12px;font-size:16px;transition:0.3s;
        }
        select:focus, input[type="text"]:focus{
            outline:none;border-color:#feba02;
            box-shadow:0 0 0 4px rgba(254,186,2,0.2);
        }
        .submit-btn{
            background:#feba02;color:#003580;padding:16px 32px;
            border:none;border-radius:12px;font-size:18px;font-weight:bold;
            cursor:pointer;width:100%;transition:0.3s;
        }
        .submit-btn:hover{
            background:#e6a800;transform:translateY(-3px);
            box-shadow:0 10px 25px rgba(254,186,2,0.3);
        }
        .back-link{
            display:block;text-align:center;margin-top:30px;
            color:#003580;font-weight:600;text-decoration:none;font-size:16px;
        }
        .back-link:hover{text-decoration:underline;}
    </style>
</head>
<body>

<header>
    <div class="logo">Booking Admin</div>
    <div class="user-info">
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="index.jsp">View Site</a>
        <a href="logout.jsp">Logout</a>
    </div>
</header>

<div class="container">
    <h1 class="page-title">Add New Room</h1>
    <p class="subtitle">Fill in the details to add a new room</p>

    <%= message %>

    <div class="form-card">
        <form method="post">
            <div class="form-group">
                <label>Select Hotel</label>
                <select name="hotel_id" required>
                    <option value="" disabled selected>Choose a hotel...</option>
                    <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
                        PreparedStatement ps = con.prepareStatement("SELECT id, name, location FROM hotels ORDER BY name");
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                            out.print("<option value='" + rs.getInt("id") + "'>" + rs.getString("name") + " - " + rs.getString("location") + "</option>");
                        }
                        con.close();
                    } catch (Exception e) {
                        out.print("<option>Error loading hotels</option>");
                    }
                    %>
                </select>
            </div>

            <div class="form-group">
                <label>Room Type</label>
                <input type="text" name="type" placeholder="e.g. Deluxe Suite, Standard Room, Presidential" required>
            </div>

            <div class="form-group">
                <label>Price per Night (₹)</label>
                <input type="text" name="price" placeholder="e.g. 8500" pattern="\d+(\.\d{1,2})?" title="Enter a valid price" required>
            </div>

            <button type="submit" class="submit-btn">Add Room</button>
        </form>

        <a href="adminDashboard.jsp" class="back-link">Back to Dashboard</a>
    </div>
</div>

</body>
</html>