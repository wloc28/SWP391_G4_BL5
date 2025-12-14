<style>
    .password-container {
        position: relative;
    }

    .password-container i {
        cursor: pointer;
        width: 32px;
        height: 32px;
        position: absolute;
        top: 50%;
        right: 10px;
        transform: translateY(-50%);
    }

</style>
<div style="width: 25vw" class="container bg-body-secondary mt-5 mb-5">
    
    <form action="register" method="post">
        <input type="hidden" name="redirect" value="${param.redirect}"/>
        <div class="form-group">
            <label for="modal_email">Email:</label>
            <input oninput="msgEmail()" type="email" value="${param.email}" name="email" class="form-control" id="modal_email" placeholder="Enter email" required>
            <p class="text-danger" id="msg_email"></p>
        </div>
        <br>
        <div class="form-group ">
            <label for="password">Password:</label>
            <div class="password-container">
                <input type="password" name="password" pattern="^(?=.*[A-Za-z])(?=.*\d).{6,}$" title="Password must be at least 6 characters long and contain at least one letter and one number" class="form-control" id="regpassword" placeholder="Enter password" required>

                <i class="show-icon" onclick="showPassword()" role="img" ><svg  width="32px" height="32px" id="regshowIcon"><path d="M16 9c4.45 0 8.076 2.417 10.73 6.997a2 2 0 01-.088 2.145C23.96 21.998 20.357 24 16 24c-4.357 0-7.96-2.002-10.642-5.858a2 2 0 01-.088-2.145C7.924 11.417 11.55 9 16 9zm0 2c-3.682 0-6.682 2-9 6 2.318 3.333 5.318 5 9 5 3.682 0 6.682-1.667 9-5-2.318-4-5.318-6-9-6zm0 1a4 4 0 110 8 4 4 0 010-8zm0 2a2 2 0 100 4 2 2 0 000-4z"></path></svg></i>
            </div>
        </div>
        <br>
        <div class="form-group">
            <label for="modal_fullname">Full Name:</label>
            <input type="text" pattern="[^\d]+" title="Fullname not contain number" value="${param.name}" name="fullname" class="form-control" id="modal_fullname" placeholder="Enter full name" required>
        </div>
        <br> 
        <div class="form-group">
            <label for="gender">Gender:</label> <br>
            <input type="radio" ${param.gender=="1"||param.gender=="true"?"":"checked"} name="gender" value="0"/> Female
            <input type="radio" ${param.gender=="1"||param.gender=="true"?"checked":""} name="gender" value="1"/> Male
        </div>
        <br>
        <div class="form-group">
            <label for="modal_mobile">Mobile:</label>
            <input type="tel" pattern="[0-9]*" title="Enter character [0-9]" name="mobile" value="${param.mobile}" class="form-control" id="modal_mobile" placeholder="Enter mobile number" required>
        </div>
        <br>
        <div class="d-flex justify-content-center p-2">
            <button  type="submit" class="btn btn-primary">Register</button>
        </div>
        <br>
        <div class="d-flex justify-content-center">
            Already has account? <a href="login">Login here</a>
        </div>
    </form>
    <script>
        function showPassword() {
            var passField = document.getElementById('regpassword');
            var showIcon = document.getElementById('regshowIcon');
            if (passField.type === 'password') {
                passField.type = 'text';
                showIcon.innerHTML = '<path d="M26.73 15.997a2 2 0 01-.088 2.145C23.96 21.998 20.357 24 16 24c-1.165 0-2.276-.143-3.33-.427l1.69-1.69c.53.078 1.077.117 1.64.117 3.682 0 6.682-1.667 9-5-.756-1.304-1.584-2.395-2.484-3.274l1.414-1.412c1.027 1.006 1.962 2.237 2.8 3.683zM23.071 8.93a1 1 0 010 1.414L10.343 23.071a1 1 0 01-1.414-1.414L21.657 8.929a1 1 0 011.414 0zM16 9c.86 0 1.69.09 2.488.27l-1.758 1.757A9.817 9.817 0 0016 11c-3.682 0-6.682 2-9 6 .535.77 1.107 1.45 1.715 2.042L7.3 20.456a15.978 15.978 0 01-1.943-2.314 2 2 0 01-.088-2.145C7.924 11.417 11.55 9 16 9zm.252 10.992l3.74-3.74a4 4 0 01-3.74 3.74zm-.503-7.984l-3.741 3.74a4 4 0 013.741-3.74z"></path>';
            } else {
                passField.type = 'password';
                showIcon.innerHTML = '<path d="M16 9c4.45 0 8.076 2.417 10.73 6.997a2 2 0 01-.088 2.145C23.96 21.998 20.357 24 16 24c-4.357 0-7.96-2.002-10.642-5.858a2 2 0 01-.088-2.145C7.924 11.417 11.55 9 16 9zm0 2c-3.682 0-6.682 2-9 6 2.318 3.333 5.318 5 9 5 3.682 0 6.682-1.667 9-5-2.318-4-5.318-6-9-6zm0 1a4 4 0 110 8 4 4 0 010-8zm0 2a2 2 0 100 4 2 2 0 000-4z"></path>';
            }
        }
        function msgEmail() {
            var email = document.getElementById("modal_email").value;
            $.ajax({
                type: "GET",
                url: "registercheck",
                data: {email: email},
                success: function (response) {
                    if (response === '1') {
                        document.getElementById("msg_email").innerHTML = 'Email already used, please enter other email!';
                        document.getElementById('btnSubmit').disabled = true;
                    } else {
                        document.getElementById("msg_email").innerHTML = '';
                        document.getElementById('btnSubmit').disabled = false;
                    }
                }
            });
        }
    </script>
</div>