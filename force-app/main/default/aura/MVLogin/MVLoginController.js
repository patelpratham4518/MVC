({
	myAction : function(component, event, helper) {
		
	},
    forgotPassword : function(component,event,helper){
        var loginpage = component.find("loginPage");	
        var signUp = component.find("signUpPage");
        var forgotPass = component.find("forgotPasswordPage");
        
       	$A.util.addClass(loginpage,'formhide');
        $A.util.addClass(signUp,'formhide');
       	$A.util.removeClass(forgotPass,'formhide');
    },
    
    loginPage : function(component,event,helper){
        var loginpage = component.find("loginPage");	
        var forgotPass = component.find("forgotPasswordPage");
        
       	$A.util.addClass(forgotPass,'formhide');
       	$A.util.removeClass(loginpage,'formhide');
    },
    loginAuthenticate : function(component,event,helper){
        var emailAddress = component.get("v.UserName")
        var enteredPassword = component.get("v.Password"); 
        var errorMessage = "Email Address or Password is Incorrect !"
        var homeP = component.find('homePage');
        var loginpage = component.find("loginPage");	
        var forgotPass = component.find("forgotPasswordPage");
        var logoDiv = component.find("logoDiv");
        

        console.log(emailAddress);
        console.log(enteredPassword);
        
        var action  = component.get("c.loginAuthentication");
        action.setParams({
            "email":emailAddress,
            "pass":enteredPassword
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=="SUCCESS"){
                var result = response.getReturnValue();
                if(result=='Success'){
                	$A.util.addClass(loginpage,'formhide');
                    $A.util.addClass(forgotPass,'formhide');
                    $A.util.addClass(logoDiv,'formhide');
       				$A.util.removeClass(homeP,'formhide');
                    component.set("v.message"," ");
                }else{
					component.set("v.message",errorMessage);
                }
            }
        });
        $A.enqueueAction(action);
    }
})