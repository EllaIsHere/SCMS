<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Create New Password | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

<style>
.strength-bar {
    height: 6px;
    border-radius: 3px;
    margin: 8px 0 15px 0;
    background-color: #ddd;
    overflow: hidden;
}

.strength-fill {
    height: 100%;
    width: 0%;
    transition: all 0.3s ease;
}

.strength-fill.weak { width: 33%; background-color: #dc3545; }
.strength-fill.average { width: 66%; background-color: #ffc107; }
.strength-fill.strong { width: 100%; background-color: #28a745; }

.requirement {
    display: flex;
    align-items: center;
    margin: 8px 0;
    font-size: 14px;
}

.requirement i {
    width: 20px;
    margin-right: 10px;
    text-align: center;
}

.requirement.unmet i { color: #dc3545; }
.requirement.met i { color: #28a745; }

.btn-disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
</style>

</head>
<body>

<div class="card">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <h1 class="title md">Create new password.</h1>
    <p class="sub">Make it strong and different from your previous password.</p>

    <form action="CreateNewPasswordServlet" method="post" id="passwordForm">

        <div class="f">
            <label class="lbl">NEW PASSWORD: <span class="req">*</span></label>
            <div class="iw">
                <i class="fa-solid fa-lock ico"></i>
                <input type="password" name="new_password" id="newPassword" required placeholder="Enter new password">
            </div>
            <div class="strength-bar">
                <div class="strength-fill" id="strengthFill"></div>
            </div>
        </div>

        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
            <p style="margin: 0 0 10px 0; font-size: 13px; font-weight: bold;">Password requirements:</p>
            
            <div class="requirement unmet" id="req-length">
                <i class="fa-solid fa-circle"></i>
                <span>At least 8 characters</span>
            </div>

            <div class="requirement unmet" id="req-letter">
                <i class="fa-solid fa-circle"></i>
                <span>At least one letter</span>
            </div>

            <div class="requirement unmet" id="req-number">
                <i class="fa-solid fa-circle"></i>
                <span>Contains a number</span>
            </div>

            <div class="requirement unmet" id="req-special">
                <i class="fa-solid fa-circle"></i>
                <span>Contains a special character</span>
            </div>

            <div class="requirement unmet" id="req-match">
                <i class="fa-solid fa-circle"></i>
                <span>Password match</span>
            </div>
        </div>

        <div class="f">
            <label class="lbl">CONFIRM NEW PASSWORD: <span class="req">*</span></label>
            <div class="iw">
                <i class="fa-solid fa-lock ico"></i>
                <input type="password" name="confirm_password" id="confirmPassword" required placeholder="Confirm password">
            </div>
        </div>

        <button type="submit" class="btn btn-y btn-disabled" id="submitBtn" disabled>
            SET NEW PASSWORD
        </button>

    </form>

</div>

<script>
const newPassword = document.getElementById('newPassword');
const confirmPassword = document.getElementById('confirmPassword');
const strengthFill = document.getElementById('strengthFill');
const submitBtn = document.getElementById('submitBtn');

const requirements = {
    'req-length': (pwd) => pwd.length >= 8,
    'req-letter': (pwd) => /[a-zA-Z]/.test(pwd),
    'req-number': (pwd) => /\d/.test(pwd),
    'req-special': (pwd) => /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pwd),
    'req-match': (pwd) => pwd && confirmPassword.value && pwd === confirmPassword.value
};

function checkPassword() {
    const pwd = newPassword.value;
    let strength = 0;
    let metRequirements = 0;

    // Update requirements
    Object.entries(requirements).forEach(([id, check]) => {
        const req = document.getElementById(id);
        const isMet = check(pwd);
        
        req.classList.toggle('met', isMet);
        req.classList.toggle('unmet', !isMet);
        
        if(isMet && id !== 'req-match') metRequirements++;
    });

    // Calculate strength
    if(pwd.length >= 8) strength++;
    if(/[a-zA-Z]/.test(pwd)) strength++;
    if(/\d/.test(pwd)) strength++;
    if(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pwd)) strength++;

    strengthFill.className = 'strength-fill';
    if(strength === 1) strengthFill.classList.add('weak');
    else if(strength === 2) strengthFill.classList.add('average');
    else if(strength >= 3) strengthFill.classList.add('strong');

    // Enable submit button if all requirements met
    const allMet = Object.entries(requirements).every(([, check]) => check(pwd));
    submitBtn.disabled = !allMet;
    submitBtn.classList.toggle('btn-disabled', !allMet);
}

newPassword.addEventListener('input', checkPassword);
confirmPassword.addEventListener('input', checkPassword);

document.getElementById('passwordForm').addEventListener('submit', (e) => {
    e.preventDefault();
    if(newPassword.value !== confirmPassword.value) {
        alert('Passwords do not match');
        return;
    }
    document.getElementById('passwordForm').submit();
});
</script>

</body>
</html>