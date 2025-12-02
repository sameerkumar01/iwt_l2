<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LuxStay - Book Hotels in India</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{
            background: linear-gradient(rgba(0,0,0,0.5),rgba(0,0,0,0.6)),
                        url('https://images.unsplash.com/photo-1522706323590-d12735c8ea97?w=1600') center/cover;
            min-height:100vh; color:white;
        }
        header{
            background:#003580; padding:20px 40px; display:flex; justify-content:space-between; align-items:center;
        }
        .logo{font-size:28px; font-weight:bold;}
        .user-info a{color:white; margin-left:20px; text-decoration:none; font-weight:500;}
        .user-info a:hover{text-decoration:underline;}

        .hero{
            text-align:center; padding:120px 20px;
        }
        .hero h1{font-size:48px; margin-bottom:20px;}
        .hero p{font-size:22px; margin-bottom:40px;}

        .search-box{
            background:white; color:#333; padding:40px; border-radius:16px; max-width:800px; margin:0 auto;
            box-shadow:0 20px 50px rgba(0,0,0,0.4);
        }
        .search-box h2{color:#003580; margin-bottom:25px; text-align:center;}
        .search-box input[type="text"], .search-box input[type="date"]{
            width:100%; padding:16px; margin:12px 0; border:1px solid #ccc; border-radius:10px; font-size:16px;
        }
        .search-box input[type="submit"]{
            width:100%; padding:18px; background:#feba02; color:#003580; border:none; border-radius:10px;
            font-size:18px; font-weight:bold; cursor:pointer; margin-top:20px;
        }
        .search-box input[type="submit"]:hover{background:#e6a800;}
    </style>
</head>
<body>

<header>
    <div class="logo">LuxStay</div>
    <div class="user-info">
        <% if(session.getAttribute("user")==null){ %>
            <a href="login.jsp">Sign In</a>
            <a href="register.jsp">Register</a>
        <% } else { %>
            Welcome, <b><%= session.getAttribute("user") %></b>
            <a href="myBookings.jsp">My Bookings</a>
            <a href="logout.jsp">Logout</a>
            <% if("admin".equals(session.getAttribute("role"))){ %>
                <a href="adminDashboard.jsp">Admin Panel</a>
            <% } %>
        <% } %>
    </div>
</header>

<div class="hero">
    <h1>Find Your Perfect Hotel</h1>
    <p>Best prices • Free cancellation • Instant confirmation</p>

    <div class="search-box">
        <h2>Search Hotels</h2>
        <form action="searchResults.jsp" method="get">
            <input type="text" name="location" placeholder="Where are you going? (e.g. Delhi, Mumbai, Bhubaneshwar)" required>
            
            <input type="date" name="checkin" required>
            
            <input type="date" name="checkout" required>
            
            <input type="submit" value="Search Hotels">
        </form>
    </div>
</div>

</body>
</html>