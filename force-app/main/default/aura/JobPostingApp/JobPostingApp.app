<!-- <aura:application extends='force:slds' >
    <c:JopbPosting/>
</aura:application>-->

<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
    <aura:dependency resource="c:JopbPosting"/>
</aura:application>