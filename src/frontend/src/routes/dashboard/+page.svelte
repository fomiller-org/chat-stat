<svelte:head>
	<title>About</title>
	<meta name="description" content="About this app" />
        <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
</svelte:head>

<div class="text-column">
	<h1 class="text-3xl font-bold underline ">Dashboard</h1>

	<p>
		My dashboard page
	</p>
</div>
<Chart/>

<script>
    import Chart from '../Chart.svelte';
    import { browser } from '$app/environment';

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
            name: "New users",
            data: [6500, 6418, 6456, 6526, 6356, 6456],
            color: "#1A56DB",
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

if (browser) {
    if (document.getElementById("area-chart") && typeof ApexCharts !== 'undefined') {
        const chart = new ApexCharts(document.getElementById("area-chart"), options);
        console.log(options);
        chart.render();
        myCallback();
        window.setInterval(myCallback, 60000);

        async function myCallback() {
            let url = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com/api/emote/average/sodapoppin/xdd/300"
            const response = await fetch(url);
            const movies = await response.json();
            console.log(movies);
            let data = []
            movies["rows"].forEach((element) => data.push(element[1]));
            console.log(data)
                chart.updateSeries([{
                name: "New users",
                data: data,
                color: "#1A56DB",
            }]);

        }
    }
}
</script>
