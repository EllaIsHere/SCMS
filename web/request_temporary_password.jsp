<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Temporary Password Sent | TIP-SC</title>

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
        <i class="fa-solid fa-envelope-circle-check" style="font-size: 60px; color: #28a745;"></i>
    </div>

    <h1 class="title md" style="text-align: center;">Temporary password sent!</h1>
    <p class="sub" style="text-align: center;">Check your inbox at <strong><%= session.getAttribute("tempPasswordEmail") %></strong></p>

    <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0; text-align: left;">
        <ul style="margin: 0; padding-left: 20px;">
            <li>Didn't receive it? Check your Spam or Junk folder.</li>
            <li>Your temp password expires in 10 minutes and is valid for one sign-in only.</li>
            <li>You'll be prompted to set a permanent password on first login.</li>
        </ul>
    </div>

    <a href="login.jsp" class="btn btn-y" style="display: block; text-align: center; text-decoration: none;">
        BACK TO SIGN IN
    </a>

</div>

</body>
</html>