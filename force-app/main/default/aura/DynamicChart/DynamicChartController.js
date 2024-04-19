({
    afterScriptsLoaded : function(component, event, helper) 
    {
        var jsonData = component.get("v.data");
        var dataObj = JSON.parse(jsonData);
        console.log('jsonData===',jsonData);
        console.log('dataObj===',dataObj);
        new Highcharts.Chart({
            chart: {
                renderTo: component.find("chart").getElement(),
                type: component.get("v.chartType")
            },
            title: {
                text: component.get("v.chartTitle")
            },
            subtitle: {
                text: component.get("v.chartSubTitle")
            },
            xAxis: {
                categories: component.get("v.xAxisCategories"),
                crosshair: true
            },
            yAxis: {
                min: 0,
                title: 
                {
                    text: component.get("v.yAxisParameter")
                }
            },
            tooltip: 
            {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                column: {
                    pointPadding: 0.2,
                    borderWidth: 0
                }
            },
            series: dataObj
        });
    }
})