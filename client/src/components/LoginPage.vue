<template>
    <div class="login-pages">
        <div class="container">
            <div class="box"></div>
            <div class="container-forms">
                <div class="container-info">
                    <div class="info-item">
                        <div class="table">
                            <div class="table-cell">
                                <p>
                                    Have an account?
                                </p>
                                <div class="btn" id="back_btn" @click="btnBackClicked()">
                                    Log in
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="info-item">
                        <div class="table">
                            <div class="table-cell">
                                <p>
                                    Don't have an account?
                                </p>
                                <div class="btn" id="signup_btn" @click="btnSignUpClicked()">
                                    Sign up
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="container-form">
                    <div class="form-item log-in">
                        <div class="table">
                            <div class="table-cell">
                                <form action="http://172.16.61.101:3001/auth/Gplus" method="post">

                                    <button class="googleAuthBtn" type="submit">Use Google Account</button>
                                </form> 
                                <div class="dialog--nux-seperator" id="seprator"> or </div>
                                <div>
                                <Tabs type="card" value="1" @on-click=tabsClicked>
                                        <TabPane label="Standard" name="1">
                                                <input placeholder="Email" tabindex="1" type="email" name="e" id="email_input" value="" v-model="emailId" v-on:change="enableButtons()">
                                                <input placeholder="Password" tabindex="2" type="password" name="p" id="password_input" v-model="pwd" @keyup.enter="btnLogInClicked()">
                                                <div tabindex="3" class="btn" id="login_btn" @click="btnLogInClicked()" @keyup.enter="btnLogInClicked()">Log in</div>
                                        </TabPane>
                                        <TabPane label="LDAP" name="2">
                                                <input placeholder="LDAP Username" tabindex="4" type="email" name="e" id="ldap_username" value="" v-model="emailId" v-on:change="enableButtons()">
                                                <input placeholder="Password" tabindex="5" type="password" name="p" id="password_input_ldap" v-model="pwd" @keyup.enter="btnLogInClicked()">
                                                <div tabindex="6" class="btn" id="login_btn" @click="btnLogInClicked()" @keyup.enter="btnLogInClicked()">Log in</div>
                                        </TabPane>
                                </Tabs>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="form-item sign-up">
                        <div class="table">
                            <div class="table-cell">
                                <input placeholder="Email" tabindex="7" type="email" name="e" id="emailInput" value="" v-model="emailId" v-on:change="enableButtons()">
                                <input placeholder="Password" tabindex="8" type="password" name="p" id="passwordInput" v-model="pwd">
                                <input placeholder="Confirm Password" tabindex="9" type="password" v-model="confPwd" id="confirmpwd">
                                <div tabindex="10" class="btn" id="signup_btn" @click="btnSubmitClicked()">
                                    Submit
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</template>

<script>
    /* eslint-disable*/
    import Vue from 'vue'
    import Resource from 'vue-resource'
    import CmnFunc from './CommonFunc.js'
    import notify from './notify.js'
    import * as services from '../services'
    import VueRouter from 'vue-router'
    import iView from 'iview';
    import 'iview/dist/styles/iview.css';
    import locale from 'iview/dist/locale/en-US';

    Vue.use(iView, { locale });

    Vue.use(iView);

    Vue.use(Resource)
    Vue.use(VueRouter)
    $(document).ready(function () {

        $("#login_btn").attr('disabled', true);
    });

    export default {
        //   el: '#loginPage',
        data: function () {
            return {
                emailId: '',
                pwd: '',
                confPwd: '',
                passData: 'Send to next vue..',
                selectedTabIndex: 1
            }
        },
        created() {
            console.log('created called')
            var url_string = window.location.href;
            var url = new URL(url_string);

            var token = url.searchParams.get('token')
            if (token) {
                console.log('TOKEN exist')
                this.$store.commit('SAVE_USERTOKEN', token)
                this.$router.replace('/loadProcess')
                //this.userDetail(this)
                //this.getAccessTokenAPI(code)
            }

            var id = url.searchParams.get('ob_id')
            if (id) {
                console.log('//socialAuth....')
                this.$store.state.googleId = id
                this.$store.commit('googleId')
                this.$router.replace('/socialAuth')
            }
        },
        computed: {
            uname: function () {
                return this.$store.state.userObject.email
            }
        },
        methods: {
            login() {
                $(".container").toggleClass("log-in");
            },
            tabsClicked(val){
                this.emailId = ''
                this.pwd = ''
                this.confPwd = ''
                console.log('value is:',val);
                this.selectedTabIndex = val;
            },
            btnSignUpClicked() {
                this.emailId = ''
                this.pwd = ''
                this.confPwd = ''
                $(".container").toggleClass("log-in");
            },
            btnSubmitClicked() {
                var trimmedEmail = this.emailId.trim()
                var trimmedPwd = this.pwd.trim()
                var trimmedConfPwd = this.confPwd.trim()

                var validateEmail = CmnFunc.checkBlankField(trimmedEmail)
                if (!validateEmail) {
                    $("#emailInput").notify("Email address should not be blank")
                    return
                }

                var validEmail = CmnFunc.checkValidEmail(trimmedEmail)
                if (!validEmail) {
                    $("#emailInput").notify("Please enter valid email address")
                    return
                }

                var validatePwd = CmnFunc.checkBlankField(trimmedPwd)
                if (!validatePwd) {
                    $("#passwordInput").notify("Password should not be blank")
                    return
                }
                var validateConfPwd = CmnFunc.checkBlankField(trimmedConfPwd)
                if (!validateConfPwd) {
                    $("#confirmpwd").notify("Confirm password field should not be blank")
                    return
                }
                var matchPwd = CmnFunc.matchPassword(trimmedPwd, trimmedConfPwd)
                if (!matchPwd) {
                    $("#confirmpwd").notify("Password and Confirm password fields do not match")
                    return
                }
                var self = this
                this.$store.dispatch('userRegistrationProcess', { 'email': trimmedEmail, 'password': trimmedPwd, 'signup_type': 'email', 'image_url': '' })
                    .then(function (response) {
                        console.log('response successful')
                        self.emailId = ''
                        self.pwd = ''
                        self.confPwd = ''
                        $('#confirmpwd').hide();
                        $('#login_btn').show()
                        $('.title').text('Log In')
                        $('#signup_btn').text('Sign Up')
                        $('#google_auth_button').show()
                        $('#seprator').show()
                        $('#back_btn').hide()
                        $("#login_btn").attr('disabled', true);
                    })
                    .catch(function (error) {
                        console.log('error with signup')
                        $("#email_input").notify(error.message)
                    })
                $(".container").toggleClass("log-in");
            },
            btnLDAPPressed() {
                var self = this
                // CmnFunc.resetProjectDefault()
                console.log('LOG IN--> userloginprocess')
                this.$store.dispatch('signInWithLDAP', { 'userid': 'xxxx', 'passwd': 'xxxx' })
                    .then(function (response) {
                        console.log('LDAP response successful');
                        console.log('LOG IN--> response', response)
                        self.$store.state.isAuthorized = true
                        self.$store.commit('authorize')
                        self.userDetail(self)
                    })
                    .catch(function (error) {
                        $.notify.defaults({ className: "error" })
                        $.notify(error.message, { globalPosition: "top center" })
                    });
            },
            insertUserData(emailID, pwd, usertype, profilePic, uname) {
                //insert user into rethink db
                this.$http.post('/insertUsers', {
                    email: emailID,
                    password: pwd,
                    username: uname,
                    role: '',
                    aboutme: '',
                    firstname: '',
                    signup_type: usertype,
                    image_url: profilePic,
                    image_name: ''
                    // dob: new Date()
                }).then(response => response.json())
                    .then(json => {
                        if (json.inserted) {
                            console.log('data successfully inserted')
                            $('#confirmpwd').hide();
                            $('#login_btn').show()
                            $('.title').text('Log In')
                            $('#signup_btn').text('Sign Up')
                            this.emailId = ''
                            this.pwd = ''
                            this.confPwd = ''
                        }
                    })
            },
            btnLogInClicked() {
                console.log('selectedTabIndex value is:',this.selectedTabIndex);
                var trimmedEmail = this.emailId.trim()
                var trimmedPwd = this.pwd.trim()

                var validateEmail = CmnFunc.checkBlankField(trimmedEmail)

                if (!validateEmail) {
                    if(this.selectedTabIndex == 1){
                        $("#email_input").notify("Email address should not be blank")
                    }else{
                        $("#ldap_username").notify("LDAP username should not be blank")
                    }
                    return
                }

                var validEmail = CmnFunc.checkValidEmail(trimmedEmail)
                if (!validEmail && this.selectedTabIndex == 1) {
                    $("#email_input").notify("Please enter valid email address")
                    return
                }

                var validatePwd = CmnFunc.checkBlankField(trimmedPwd)
                if (!validatePwd) {
                    if(this.selectedTabIndex == 1){
                        $("#password_input").notify("Password should not be blank")
                    }else{
                        $("#password_input_ldap").notify("Password should not be blank")
                    }
                    return
                }

                var self = this
                CmnFunc.resetProjectDefault()
                console.log('LOG IN--> userloginprocess')

                this.$store.dispatch('userLoginProcess', { 'email': trimmedEmail, 'password': trimmedPwd, 'userType':this.selectedTabIndex})
                    .then(function () {
                        self.$store.state.isAuthorized = true
                        self.$store.commit('authorize')
                        self.userDetail(self)
                    })
                    .catch(function (error) {
                        $.notify.defaults({ className: "error" })
                        $.notify(error.message, { globalPosition: "top center" })
                    });

            },
            userDetail(self) {
                self.$store.dispatch('getUserDetail')
                    //  self.$store.dispatch('getUserRegister')                           
                    .then(function () {
                        self.$router.replace('/navbar/mainapp')
                    })
                    .catch(function (error) {
                        if (error.response.status === 401) {
                            return
                        }
                        $.notify.defaults({ className: "error" })
                        $.notify(error.message, { globalPosition: "top center" })
                    })
            },
            btnBackClicked() {
                $(".container").toggleClass("log-in");

                this.emailId = ''
                this.pwd = ''
                this.confPwd = ''
            },
            enableButtons() {
                var trimmedEmail = this.emailId.trim()
                if (trimmedEmail.length >= 1) {
                    $('#login_btn').removeClass('is-disabled')
                    $("#login_btn").attr('disabled', false);

                    $('#signup_btn').removeClass('is-disabled')
                    $("#signup_btn").attr('disabled', false);
                } else {
                    if ($('#signup_btn').text() == "Submit") {
                        $('#signup_btn').addClass('is-disabled')
                        $("#signup_btn").attr('disabled', true);
                    }
                    $('#login_btn').addClass('is-disabled')
                    $("#login_btn").attr('disabled', true);
                }
            }
        }
    }

</script>
<style>
    .login-pages {
        background-color: #5356ad;
        position: fixed;
        left: 0;
        right: 0;
        top: 0;
        bottom: 0;
    }
</style>