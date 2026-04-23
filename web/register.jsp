<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Register | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

</head>
<body>

<div class="card wide">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <a href="login.jsp" class="back">
        <i class="fa-solid fa-arrow-left"></i> Back to Sign In
    </a>

    <h1 class="title md">REGISTER AN ACCOUNT</h1>
    <p class="sub">Create your account by filling in the required information.</p>

    <div class="role-lbl">ROLE:</div>

    <div class="role-tabs">
        <button type="button" class="rtab on" id="tab-student"
                onclick="setRole('student')">
            <i class="fa-solid fa-graduation-cap"></i>
            STUDENT
        </button>

        <button type="button" class="rtab" id="tab-manager"
                onclick="setRole('manager')">
            <i class="fa-solid fa-clipboard-list"></i>
            MANAGER
        </button>

        <button type="button" class="rtab" id="tab-admin"
                onclick="setRole('admin')">
            <i class="fa-solid fa-desktop"></i>
            ADMIN
        </button>
    </div>

    <form action="RegisterServlet" method="post" onsubmit="return validateForm()">

        <!-- Hidden role -->
        <input type="hidden" name="role" id="selectedRole" value="student">

        <!-- ================= STUDENT ================= -->
        <div id="fields-student">
            <div class="g3">

                <div class="f">
                    <label class="lbl">LAST NAME *</label>
                    <div class="iw no-icon">
                        <input type="text" name="last_name" id="student_last_name" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">FIRST NAME *</label>
                    <div class="iw no-icon">
                        <input type="text" name="first_name" id="student_first_name" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">CAMPUS *</label>
                    <div class="iw no-icon">
                        <select name="campus" id="student_campus" required>
                            <option value="">Select Campus</option>
                            <option value="MNL">Manila</option>
                            <option value="QC">Quezon City</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">STUDENT ID *</label>
                    <div class="iw no-icon">
                        <input type="text" name="school_id" id="student_id" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">SCHOOL EMAIL *</label>
                    <div class="iw no-icon">
                        <input type="email" name="email" id="student_email" required>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">PROGRAM *</label>
                    <div class="iw no-icon">
                        <select name="program" id="student_program" required>
                            <option value="">Select Program</option>
                            <option value="BSIT">BS Information Technology</option>
                            <option value="BSCS">BS Computer Science</option>
                            <option value="BSCE">BS Civil Engineering</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">PASSWORD *</label>
                    <div class="iw">
                        <i class="fa-solid fa-lock ico"></i>
                        <input type="password" name="password" id="student_password" required placeholder="Enter your password">
                    </div>
                </div>

            </div>
        </div>

        <!-- ================= MANAGER ================= -->
        <div id="fields-manager" style="display:none">
            <div class="g3">

                <div class="f">
                    <label class="lbl">LAST NAME *</label>
                    <div class="iw no-icon">
                        <input type="text" name="last_name" id="manager_last_name">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">FIRST NAME *</label>
                    <div class="iw no-icon">
                        <input type="text" name="first_name" id="manager_first_name">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">CAMPUS *</label>
                    <div class="iw no-icon">
                        <select name="campus" id="manager_campus">
                            <option value="">Select Campus</option>
                            <option value="MNL">Manila</option>
                            <option value="QC">Quezon City</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">EMPLOYEE ID *</label>
                    <div class="iw no-icon">
                        <input type="text" name="school_id" id="manager_id">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">SCHOOL EMAIL *</label>
                    <div class="iw no-icon">
                        <input type="email" name="email" id="manager_email">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">DEPARTMENT *</label>
                    <div class="iw no-icon">
                        <select name="department" id="manager_department">
                            <option value="">Select Department</option>
                            <option value="CCS">College of Computer Studies</option>
                            <option value="COE">College of Engineering</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">PASSWORD *</label>
                    <div class="iw">
                        <i class="fa-solid fa-lock ico"></i>
                        <input type="password" name="password" id="manager_password" placeholder="Enter your password">
                    </div>
                </div>

            </div>
        </div>

        <!-- ================= ADMIN ================= -->
        <div id="fields-admin" style="display:none">
            <div class="g3">

                <div class="f">
                    <label class="lbl">LAST NAME *</label>
                    <div class="iw no-icon">
                        <input type="text" name="last_name" id="admin_last_name">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">FIRST NAME *</label>
                    <div class="iw no-icon">
                        <input type="text" name="first_name" id="admin_first_name">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">CAMPUS *</label>
                    <div class="iw no-icon">
                        <select name="campus" id="admin_campus">
                            <option value="">Select Campus</option>
                            <option value="MNL">Manila</option>
                            <option value="QC">Quezon City</option>
                        </select>
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">EMPLOYEE ID *</label>
                    <div class="iw no-icon">
                        <input type="text" name="school_id" id="admin_id">
                    </div>
                </div>

                <div class="f s2">
                    <label class="lbl">SCHOOL EMAIL *</label>
                    <div class="iw no-icon">
                        <input type="email" name="email" id="admin_email">
                    </div>
                </div>

                <div class="f">
                    <label class="lbl">PASSWORD *</label>
                    <div class="iw">
                        <i class="fa-solid fa-lock ico"></i>
                        <input type="password" name="password" id="admin_password" placeholder="Enter your password">
                    </div>
                </div>

            </div>
        </div>

        <button type="submit" class="btn btn-y">
            CREATE ACCOUNT
        </button>

    </form>

    <div class="links">
        <a href="login.jsp">Already have an account? Sign In</a>
    </div>

</div>

<script>
function setRole(role){
    document.getElementById("selectedRole").value = role;

    ["student","manager","admin"].forEach(r=>{
        document.getElementById("tab-"+r).classList.toggle("on", r===role);
        document.getElementById("fields-"+r).style.display = r===role ? "" : "none";
    });
}

function validateForm() {
    const role = document.getElementById("selectedRole").value;
    const firstName = document.querySelector(`#${role}_first_name`).value.trim();
    const lastName = document.querySelector(`#${role}_last_name`).value.trim();
    const email = document.querySelector(`#${role}_email`).value.trim();
    const password = document.querySelector(`#${role}_password`).value.trim();

    if(!firstName || !lastName || !email || !password) {
        alert("Please fill in all required fields");
        return false;
    }

    if(password.length < 6) {
        alert("Password must be at least 6 characters");
        return false;
    }

    console.log("Form validated. Submitting...");
    return true;
}
</script>

</body>
</html>