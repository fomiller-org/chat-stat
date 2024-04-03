<svelte:head>
	<title>Dashboard</title>
	<meta name="description" content="Chat Stat Dashboard" />
        <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
</svelte:head>

<div class="text-column">
	<h1 class="text-3xl font-bold text-purple-600">Chat Stat</h1>
</div>


<DashboardInput/>

{#if $channel}
    <Donut/>
{/if}
{#if $emote_chart_visible}
    <Chart/>
{/if}

<!-- {#if $channel} -->
<!-- <iframe src={twitch_chat_embed} height="500" width="300"> </iframe> -->
<!-- {/if} -->

<script>
	/** @type {import('./$types').PageData} */
    import Chart from '../Chart.svelte';
    import Donut from '../Donut.svelte';
    import DashboardInput from '../DashboardInput.svelte';
    import { browser } from '$app/environment';
    import {emote, channel, chart_data, emote_chart_visible, setChartData, resetChartData} from './store.ts'
    // let twitch_chat_embed = `https://www.twitch.tv/embed/${$channel}/chat?parent=localhost`;
</script>
