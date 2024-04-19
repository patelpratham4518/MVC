
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js" ></script>
<script>
$(document).ready(function(){
  $("#inputCredential").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    console.log('Test');
    console.log(value);
    $("#credentialList p").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
});
</script>