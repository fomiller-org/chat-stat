/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
    const url = "https://chat-stat-api.fomiller-cluster.dev.aws.fomillercloud.com/api/channel/emotes/sodapoppin";
    const response = await fetch(url);
    const json = await response.json();
    return json
}
