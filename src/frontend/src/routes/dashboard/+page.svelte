<svelte:head>
	<title>About</title>
	<meta name="description" content="About this app" />
        <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
</svelte:head>

<div class="text-column">
	<h1 class="text-3xl font-bold text-purple-600">Chat Stat</h1>
</div>


<DashboardInput/>
<Chart/>

<script>
	/** @type {import('./$types').PageData} */
    import Chart from '../Chart.svelte';
    import DashboardInput from '../DashboardInput.svelte';
    import { browser } from '$app/environment';
    import {emote, channel, chart_data, setChartData, resetChartData} from './store.ts'
    
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

    // function logEmote() {
    //     if ( data["emotes"].includes(emote) ) {
    //         console.log(emote);
    //     } else {
    //         console.log("not found")
    //     }
    // }
    
    // async function setChannel() {
    //     const domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
    //     let endpoint = `api/channel/emotes/${channel}`;
    //     let url = `${domain}/${endpoint}`;
    //     let response = await fetch(url);
    //     let json = await response.json();
    //     data["emotes"] = json["emotes"];
    //     console.log(data["emotes"]);
    // }

    async function updateChart(chart) {
        if ($emote != '') {
            console.log("updating chart");
            console.log($emote);
            const domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
            let endpoint = `api/emote/average/${$channel}/${$emote}/60`;
            let url = `${domain}/${endpoint}`;
            console.log(url)
            let response = await fetch(url);
            let data = await response.json();
            console.log(data)
            let clean_data = [];
            resetChartData()
            data["rows"].forEach((element) => clean_data.push(element[1]));
            setChartData(clean_data) 
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
