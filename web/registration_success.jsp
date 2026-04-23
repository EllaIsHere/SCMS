<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Registration Successful | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

</head>
<body>

<div class="card">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <div style="text-align: center; margin: 30px 0;">
        <i class="fa-solid fa-circle-check" style="font-size: 60px; color: #28a745;"></i>
    </div>

    <h1 class="title md" style="text-align: center;">Registration Successful!</h1>
    <p class="sub" style="text-align: center;">Your account has been created. You can now sign in with your email and password.</p>
    <p style="text-align: center; color: #666; margin-top: 10px;">
        <strong>Email:</strong> <%= session.getAttribute("otpEmail") %>
    </p>

    <a href="login.jsp" class="btn btn-y" style="display: block; text-align: center; text-decoration: none; margin-top: 20px;">
        PROCEED TO LOGIN
    </a>

</div>

</body>
</html>