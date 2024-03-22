import { writable, readable } from 'svelte/store';

export const emote = writable("");
export const channel = writable("");
export const chart_data = writable([]);
export const channel_emotes = writable([]);
export const emote_chart_visible = writable(false);
export const chart_options = readable({
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
            name: `${emote}s`,
            data: [],
            color: "#9146FF",
        },
    ],
    xaxis: {
        categories: [],
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
})

export function resetChartData() {
    chart_data.set([])
}

export function setChartData(data) {
    chart_data.update((state) => state = data)
}
