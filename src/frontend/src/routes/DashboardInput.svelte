<script>
    import {emote, channel, channel_emotes, chart_data, setChartData} from './dashboard/store.ts'
	/** @type {import('./$types').PageData} */
	// export let data;
    // export let emote;
    // export let channel;
    async function setChannel() {
        console.log("MYCHANNEL: ",$channel)
        console.log($emote)
        const domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
        let endpoint = `api/channel/emotes/${$channel}`;
        console.log(endpoint)
        let url = `${domain}/${endpoint}`;
        let response = await fetch(url);
        let json = await response.json();
        $channel_emotes = json["emotes"];
        console.log($channel_emotes);
        let avg_domain = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com";
        let avg_endpoint = `api/emote/average/${$channel}/${$emote}/60`;
        let avg_url = `${avg_domain}/${avg_endpoint}`;
        console.log(avg_url)
        response = await fetch(avg_url);
        let data = await response.json();
        console.log(data)
        let clean_data = [];
        data["rows"].forEach((element) => clean_data.push(element[1]));
        setChartData(clean_data) 
        console.log($chart_data);
    }
</script>
<form>
    <div class="grid gap-6 mb-6 md:grid-cols-1">
        <div>
            <label for="emote" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Emote</label>
            <input bind:value="{$emote}" type="search" id="emote" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search Emotes..." required />
        </div>
        <div>
            <label for="channel" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Channel</label>
            <input bind:value="{$channel}" type="search" id="channel" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search Channel..." required />
        </div>
    <button on:click={setChannel} type="submit" class="text-white bg-purple-600 hover:bg-purple-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
</form>
