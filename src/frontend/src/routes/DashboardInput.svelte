<script>
    import {emote, channel, channel_emotes, emote_chart_visible, chart_data, setChartData} from './dashboard/store.ts'
    let emoteInputVisible = false;
    
    async function setChannel() {
        emoteInputVisible = false;
        $emote_chart_visible = false;
        setChartData([]) 
        $channel = document.getElementById("channelInput").value
        const domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
        let endpoint = `api/channel/emotes/${$channel}`;
        let response = await fetch(`${domain}/${endpoint}`);
        let data = await response.json();
        $channel_emotes = data["emotes"]
        emoteInputVisible = true;
    }
    async function setEmote() {
        $emote_chart_visible = false;
        $emote = document.getElementById("emoteInput").value
        if ($channel_emotes.includes($emote)) {
            let domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
            let endpoint = `api/emote/average/${$channel}/${$emote}/60`;
            let response = await fetch(`${domain}/${endpoint}`);
            let data = await response.json();
            let x = Array.from(data["rows"], (x) => x[1])
            $emote_chart_visible = true;
            setChartData(x) 
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
        } else {
            alert(`emote ${$emote} not found in ${$channel} emotes.`)
        }
        
    }
</script>

<!-- channel form -->
<form>
    <div class="grid gap-6 mb-6 md:grid-cols-1">
        <div>
            <label for="channel" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Channel</label>
            <input type="search" id="channelInput" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search Channel..." required />
        </div>
    <button on:click={setChannel} type="submit" class="text-white bg-purple-600 hover:bg-purple-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
</form>

<!-- emote form -->
{#if emoteInputVisible}
<form>
    <div class="grid gap-6 mb-6 md:grid-cols-1">
        <div>
            <label for="emote" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Emote</label>
            <input type="text" list="emoteList" id="emoteInput" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search Emotes..." required />
            <datalist id="emoteList">
            {#each $channel_emotes as emote}
                <option>{emote}</option>
            {/each}
            </datalist>
        </div>
    <button on:click={setEmote} type="submit" class="text-white bg-purple-600 hover:bg-purple-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
</form>
{/if}
