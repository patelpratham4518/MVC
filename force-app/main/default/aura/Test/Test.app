<!--<aura:application extends="force:slds">
<c:RebateComponent/>
    <c:questions/>
</aura:application>-->

<aura:application extends="ltng:outApp" access="GLOBAL" implements="ltng:allowGuestAccess" extensible="force:slds">
    <aura:dependency resource="questions" />
</aura:application>