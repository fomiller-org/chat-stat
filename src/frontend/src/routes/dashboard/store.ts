import { writable, readable } from 'svelte/store';

export const emote = writable("");
export const channel = writable("");
export const chart_data = writable([]);
export const channel_emotes = writable([]);
export const emote_chart_visible = writable(false);
export const limit = readable("10");
export const interval = readable("120m");
export const top_emotes = writable([])
export const donut_chart_options = writable({
    series: [],
    colors: ["#1C64F2", "#16BDCA", "#FDBA8C", "#E74694"],
    chart: {
        height: 320,
        width: "100%",
        type: "donut",
    },
    stroke: {
        colors: ["transparent"],
        lineCap: "",
    },
    plotOptions: {
        pie: {
            donut: {
                labels: {
                    show: true,
                    name: {
                        show: true,
                        fontFamily: "Inter, sans-serif",
                        offsetY: 20,
                    },
                    total: {
                        showAlways: true,
                        show: true,
                        label: "Emotes",
                        fontFamily: "Inter, sans-serif",
                        formatter: function(w) {
                            const sum = w.globals.seriesTotals.reduce((a, b) => {
                                return a + b
                            }, 0)
                            return sum
                        },
                    },
                    value: {
                        show: true,
                        fontFamily: "Inter, sans-serif",
                        offsetY: -20,
                        formatter: function(value) {
                            return value
                        },
                    },
                },
                size: "80%",
            },
        },
    },
    grid: {
        padding: {
            top: -2,
        },
    },
    labels: [],
    dataLabels: {
        enabled: false,
    },
    legend: {
        position: "bottom",
        fontFamily: "Inter, sans-serif",
    },
    yaxis: {
        labels: {
            formatter: function(value) {
                return value
            },
        },
    },
    xaxis: {
        labels: {
            formatter: function(value) {
                return value
            },
        },
        axisTicks: {
            show: false,
        },
        axisBorder: {
            show: false,
        },
    },
}
)
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
