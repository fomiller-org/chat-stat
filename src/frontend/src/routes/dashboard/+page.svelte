<svelte:head>
	<title>Dashboard</title>
	<meta name="description" content="Chat Stat Dashboard" />
        <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
</svelte:head>

<div class="text-column">
	<h1 class="text-3xl font-bold text-purple-600">Chat Stat</h1>
</div>


<DashboardInput/>
<!-- {#if $emote_chart_visible} -->
    <Chart/>
<!-- {/if} -->

<script>
	/** @type {import('./$types').PageData} */
    import Chart from '../Chart.svelte';
    import DashboardInput from '../DashboardInput.svelte';
    import { browser } from '$app/environment';
    import {emote, channel, chart_data, emote_chart_visible, setChartData, resetChartData} from './store.ts'
    
    const options = {
        chart: {
            height: "100%",
            maxWidth: "100%",
            type: "area",
            fontFamily: "Inter, sans-serif",
            dropShadow: {
                enabled: false,
            },
            toolbar: {
                show: false,
            },
        },
        tooltip: {
            enabled: true,
            x: {
                show: false,
            },
        },
        fill: {
            type: "gradient",
            gradient: {
                opacityFrom: 0.55,
                opacityTo: 0,
                shade: "#1C64F2",
                gradientToColors: ["#1C64F2"],
            },
        },
        dataLabels: {
            enabled: false,
        },
        stroke: {
            width: 6,
        },
        grid: {
            show: false,
            strokeDashArray: 4,
            padding: {
                left: 2,
                right: 2,
                top: 0
            },
        },
        series: [
            {
                name: `${$emote}s`,
                data: [],
                color: "#9146FF",
            },
        ],
        xaxis: {
            categories: ['01 February', '02 February', '03 February', '04 February', '05 February', '06 February', '07 February'],
            labels: {
                show: false,
            },
            axisBorder: {
                show: false,
            },
            axisTicks: {
                show: false,
            },
        },
        yaxis: {
            show: false,
        },
    }

     async function updateChart(chart) {
         if ($emote != '') {
             console.log("updating chart");
             const domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
             let endpoint = `api/emote/average/${$channel}/${$emote}/60`;
             let response = await fetch(`${domain}/${endpoint}`);
             let data = await response.json();
             console.log(data)
             // resetChartData()
             $chart_data = Array.from(data["rows"], (x) => x[1])
             // setChartData(x) 
             console.log($chart_data);
         }
     }
    
     if (browser) {
         if (document.getElementById("area-chart") && typeof ApexCharts !== 'undefined') {
             const chart = new ApexCharts(document.getElementById("area-chart"), options);
             chart.render();
             chart_data.subscribe((data) => {
                 console.log("chart sub")
                 console.log("data", data)
                 chart.updateSeries([{
                     name: `${$emote}s`,
                     data: data,
                     color: "#9146FF",
                 }]);
             });
             window.setInterval(updateChart, 60000, chart);
         }
     }
</script>
