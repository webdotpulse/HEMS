<template>
	<div
		data-testid="visualization"
		class="visualization"
		:class="{ 'visualization--ready': transitionsEnabled }"
	>
		<div class="energy-flow-chart">
			<svg class="energy-flow-lines" viewBox="0 0 400 300" preserveAspectRatio="xMidYMid meet">
				<!-- Solar to Home -->
				<path v-if="pvConfigured" d="M 200 50 Q 200 150 200 150" class="flow-line" :class="{ 'flow-active': pvProduction > 0 }" />
				<!-- Grid to Home -->
				<path v-if="gridConfigured && gridImport > 0" d="M 50 150 Q 150 150 200 150" class="flow-line flow-active" />
				<!-- Home to Grid (Export) -->
				<path v-if="gridConfigured && pvExport > 0" d="M 200 150 Q 150 150 50 150" class="flow-line flow-active" />
				<!-- Battery to Home -->
				<path v-if="batteryConfigured && batteryDischarge > 0" d="M 350 150 Q 250 150 200 150" class="flow-line flow-active" />
				<!-- Home to Battery (Charge) -->
				<path v-if="batteryConfigured && batteryCharge > 0" d="M 200 150 Q 250 150 350 150" class="flow-line flow-active" />
			</svg>
			<div class="nodes">
				<div class="node node-home">
					<div class="node-icon"><shopicon-regular-home></shopicon-regular-home></div>
					<div class="node-label">Home</div>
					<div class="node-value">{{ fmtW(homePower, powerUnit, true) }}</div>
				</div>
				<div v-if="pvConfigured" class="node node-solar">
					<div class="node-icon"><shopicon-regular-sun></shopicon-regular-sun></div>
					<div class="node-label">Solar</div>
					<div class="node-value">{{ fmtW(pvProduction, powerUnit, true) }}</div>
				</div>
				<div v-if="gridConfigured" class="node node-grid">
					<div class="node-icon"><shopicon-regular-powersupply></shopicon-regular-powersupply></div>
					<div class="node-label">Grid</div>
					<div class="node-value">{{ gridImport > 0 ? fmtW(gridImport, powerUnit, true) : fmtW(pvExport, powerUnit, true) }}</div>
				</div>
				<div v-if="batteryConfigured" class="node node-battery">
					<div class="node-icon"><BatteryIcon :soc="batterySoc" :gridCharge="batteryGridCharge" /></div>
					<div class="node-label">Battery</div>
					<div class="node-value">{{ batteryDischarge > 0 ? fmtW(batteryDischarge, powerUnit, true) : fmtW(batteryCharge, powerUnit, true) }}</div>
				</div>
			</div>
		</div>
	</div>
</template>

<script lang="ts">
import formatter, { POWER_UNIT } from "@/mixins/formatter";
import BatteryIcon from "./BatteryIcon.vue";
import "@h2d2/shopicons/es/regular/sun";
import "@h2d2/shopicons/es/regular/home";
import "@h2d2/shopicons/es/regular/powersupply";
import { defineComponent, type PropType } from "vue";

export default defineComponent({
	name: "Visualization",
	components: { BatteryIcon },
	mixins: [formatter],
	props: {
		gridImport: { type: Number, default: 0 },
		selfPv: { type: Number, default: 0 },
		selfBattery: { type: Number, default: 0 },
		pvExport: { type: Number, default: 0 },
		batterySoc: { type: Number },
		batteryCharge: { type: Number, default: 0 },
		batteryDischarge: { type: Number, default: 0 },
		batteryHold: { type: Boolean, default: false },
		batteryGridCharge: { type: Boolean, default: false },
		pvProduction: { type: Number, default: 0 },
		homePower: { type: Number, default: 0 },
		powerUnit: { type: String as PropType<POWER_UNIT>, default: POWER_UNIT.KW },
		inPower: { type: Number, default: 0 },
		outPower: { type: Number, default: 0 },
		gridConfigured: { type: Boolean, default: false },
		pvConfigured: { type: Boolean, default: false },
		batteryConfigured: { type: Boolean, default: false },
	},
	data() {
		return { transitionsEnabled: false };
	},
	computed: {
		gridExport() {
			return this.applyThreshold(this.pvExport);
		},
		totalRaw() {
			return this.gridImport + this.selfPv + this.selfBattery + this.pvExport;
		},
		gridImportAdjusted() {
			return this.applyThreshold(this.gridImport);
		},
		selfPvAdjusted() {
			return this.applyThreshold(this.selfPv);
		},
		selfBatteryAdjusted() {
			return this.applyThreshold(this.selfBattery);
		},
		pvExportAdjusted() {
			return this.applyThreshold(this.pvExport);
		},
		totalAdjusted() {
			return (
				this.gridImportAdjusted +
				this.selfPvAdjusted +
				this.selfBatteryAdjusted +
				this.pvExportAdjusted
			);
		},
	},

	watch: {
		transitionsEnabled(newVal: boolean) {
			if (newVal && !this.transitionsEnabled) {
				// ensure screen is drawn before enabling transitions
				requestAnimationFrame(() => {
					requestAnimationFrame(() => {
						this.transitionsEnabled = true;
					});
				});
			}
		},
	},
	mounted() {
		setTimeout(() => {
			this.transitionsEnabled = true;
		}, 100);
	},
	methods: {
		applyThreshold(power: number, threshold = 2) {
			const percent = (100 / this.totalRaw) * power;
			return percent < threshold ? 0 : power;
		},
	},
});
</script>
<style scoped>
.visualization {
	position: relative;
	width: 100%;
	padding-top: 2rem;
	padding-bottom: 2rem;
}
.energy-flow-chart {
	position: relative;
	width: 100%;
	max-width: 400px;
	margin: 0 auto;
	height: 300px;
}
.energy-flow-lines {
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	z-index: 0;
}
.flow-line {
	fill: none;
	stroke: var(--evcc-gray);
	stroke-width: 4;
	stroke-linecap: round;
	stroke-dasharray: 10 10;
	opacity: 0.2;
}
.flow-active {
	stroke: var(--evcc-accent1);
	opacity: 1;
	animation: flowAnimation 1s linear infinite;
}
@keyframes flowAnimation {
	to {
		stroke-dashoffset: -20;
	}
}
.nodes {
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	z-index: 1;
}
.node {
	position: absolute;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 80px;
	height: 80px;
	background-color: var(--evcc-box);
	border-radius: 50%;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	transform: translate(-50%, -50%);
}
.node-icon {
	font-size: 1.5rem;
	margin-bottom: 0.2rem;
	color: var(--evcc-default-text);
}
.node-label {
	font-size: 0.75rem;
	color: var(--evcc-gray);
	font-weight: 600;
}
.node-value {
	font-size: 0.85rem;
	font-weight: bold;
}
.node-home {
	top: 50%;
	left: 50%;
	width: 100px;
	height: 100px;
	border: 2px solid var(--evcc-accent1);
}
.node-solar {
	top: 16.66%;
	left: 50%;
	color: var(--evcc-pv);
}
.node-grid {
	top: 50%;
	left: 12.5%;
	color: var(--evcc-grid);
}
.node-battery {
	top: 50%;
	left: 87.5%;
	color: var(--evcc-battery);
}
</style>
