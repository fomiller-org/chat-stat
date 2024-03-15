/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
    const all_emotes_url = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com/api/channel/emotes/sodapoppin";
    const response = await fetch(all_emotes_url);
    const json = await response.json();
    return json
}
