import { writable } from 'svelte/store';

export const emote = writable("");
export const channel = writable("");
export const chart_data = writable([]);
export const channel_emotes = writable([]);
export const emote_chart_visible = writable(false);

export function resetChartData() {
    chart_data.set([])
}

export function setChartData(data) {
    chart_data.update((state) => state = data)
}
