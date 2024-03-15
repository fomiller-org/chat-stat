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
	/** @type {import('./$types').PageData} */
	export let data;
    console.log(data["emotes"])
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

let name = '';
let emote = '';
let all_emotes = [];
function logEmote() {
    if ( data["emotes"].includes(emote) ) {
        console.log(emote);
    } else {
        console.log("not found")
    }
}

if (browser) {
    window.setInterval(logName, 1000);
    
    function logName() {
        if (name != '') {
            console.log(name);
        };
    }
    
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

<form class="max-w-md mx-auto">   
    <label for="default-search" class="mb-2 text-sm font-medium text-gray-900 sr-only dark:text-white">Search</label>
    <div class="relative">
        <div class="absolute inset-y-0 start-0 flex items-center ps-3 pointer-events-none">
            <svg class="w-4 h-4 text-gray-500 dark:text-gray-400" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 20">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"/>
            </svg>
        </div>
        <input bind:value={emote} type="search" id="default-search" class="block w-full p-4 ps-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search Mockups, Logos..." required />
        <button type="submit" on:click={logEmote} class="text-white absolute end-2.5 bottom-2.5 bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Search</button>
    </div>
</form>

<p>Hello {name || 'stranger'}!</p>
