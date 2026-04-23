<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Set New Password | TIP-SC</title>

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

    <h1 class="title md">Set new password</h1>
    <p class="sub">Make it strong and different from your previous password.</p>

    <div style="background-color: #e7f3ff; padding: 15px; border-radius: 8px; margin: 20px 0; text-align: center;">
        <p style="margin: 0;">This is your first login. You need to set a permanent password before proceeding.</p>
    </div>

    <a href="create_new_password.jsp" class="btn btn-y" style="display: block; text-align: center; text-decoration: none;">
        CONTINUE TO SET NEW PASSWORD
    </a>

</div>

</body>
</html>