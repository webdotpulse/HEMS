<template>
	<div
		class="energyflow position-relative"
		:class="{
			'energyflow--open': detailsOpen || detailsAlwaysOpen,
			'cursor-pointer': !detailsAlwaysOpen,
		}"
		data-testid="energyflow"
		@click="toggleDetails"
	>
		<div class="row">
			<Visualization
				class="col-12 mb-3 mb-md-4"
				:gridImport="gridImport"
				:selfPv="selfPv"
				:selfBattery="selfBattery"
				:pvExport="pvExport"
				:batteryCharge="batteryCharge"
				:batteryDischarge="batteryDischarge"
				:batteryGridCharge="batteryGridChargeActive"
				:batteryHold="batteryHold"
				:pvProduction="pvProduction"
				:homePower="homePower"
				:batterySoc="batterySoc"
				:powerUnit="powerUnit"
				:inPower="inPower"
				:outPower="outPower"
			:gridConfigured="gridConfigured"
			:pvConfigured="pvConfigured"
			:batteryConfigured="batteryConfigured"
			/>
		</div>
	</div>
</template>

<script lang="ts">
import "@h2d2/shopicons/es/filled/square";
import Visualization from "./Visualization.vue";
import formatter, { POWER_UNIT } from "@/mixins/formatter";
import settings from "@/settings";
import collector from "@/mixins/collector.js";
import { defineComponent, type PropType } from "vue";
import {
	SMART_COST_TYPE,
	type Battery,
	type Meter,
	type CURRENCY,
	type Forecast,
} from "@/types/evcc";

export default defineComponent({
	name: "Energyflow",
	components: {
		Visualization,
	},
	mixins: [formatter, collector],
	props: {
		gridConfigured: Boolean,
		experimental: Boolean,
		gridPower: { type: Number, default: 0 },
		homePower: { type: Number, default: 0 },
		pvConfigured: Boolean,
		pv: { type: Array as PropType<Meter[]>, default: () => [] },
		aux: { type: Array as PropType<Meter[]>, default: () => [] },
		ext: { type: Array as PropType<Meter[]>, default: () => [] },
		pvPower: { type: Number, default: 0 },
		batteryConfigured: { type: Boolean },
		battery: { type: Object as PropType<Battery> },
		batteryDischargeControl: { type: Boolean },
		batteryGridChargeLimit: { type: Number },
		batteryGridChargeActive: { type: Boolean },
		batteryMode: { type: String },
		tariffGrid: { type: Number },
		tariffFeedIn: { type: Number, default: 0 },
		tariffCo2: { type: Number },
		tariffPriceHome: { type: Number },
		tariffCo2Home: { type: Number },
		tariffPriceLoadpoints: { type: Number },
		tariffCo2Loadpoints: { type: Number },
		smartCostType: { type: String },
		currency: { type: String as PropType<CURRENCY> },
		prioritySoc: { type: Number },
		bufferSoc: { type: Number },
		bufferStartSoc: { type: Number },
		forecast: { type: Object as PropType<Forecast>, default: () => ({}) },
	},
	data: () => {
		return {
			detailsOpen: false,
			detailsCompleteHeight: null as number | null,
			ready: false,
		};
	},
	computed: {
		showCo2() {
			if (this.hasCo2 && !this.hasPrice) {
				return true;
			}
			return settings.energyflowCo2;
		},
		hasPrice() {
			return this.tariffGrid !== undefined;
		},
		hasCo2() {
			return this.tariffCo2 !== undefined;
		},
		hasPriceAndCo2() {
			return this.hasPrice && this.hasCo2;
		},
		gridImport() {
			return Math.max(0, this.gridPower);
		},
		pvProduction() {
			return Math.abs(this.pvPower);
		},
		batterySoc() {
			return this.battery?.soc;
		},
		batteryPower() {
			return this.battery?.power ?? 0;
		},
		batteryDevices() {
			return this.battery?.devices ?? [];
		},
		hasMultipleBatteries() {
			return this.batteryDevices.length > 1;
		},
		batteryDischarge() {
			return this.dischargePower(this.batteryPower);
		},
		batteryCharge() {
			return this.chargePower(this.batteryPower);
		},
		batteryChargeLabel() {
			return this.$t("main.energyflow.batteryCharge");
		},
		batteryDischargeLabel() {
			return this.$t(`main.energyflow.battery${this.batteryHold ? "Hold" : "Discharge"}`);
		},
		batteryHold() {
			return this.batteryMode === "hold";
		},
		consumption() {
			return this.homePower + this.batteryCharge;
		},
		selfPv() {
			return Math.min(this.pvProduction, this.consumption);
		},
		selfBattery() {
			return Math.min(this.batteryDischarge, this.consumption - this.selfPv);
		},
		pvExport() {
			return Math.max(0, this.gridPower * -1);
		},
		powerUnit() {
			const watt = Math.max(this.gridImport, this.selfPv, this.selfBattery, this.pvExport);
			if (watt >= 1_000_000) {
				return POWER_UNIT.MW;
			} else if (watt >= 1000) {
				return POWER_UNIT.KW;
			} else {
				return POWER_UNIT.W;
			}
		},
		inPower() {
			return this.gridImport + this.pvProduction + this.batteryDischarge;
		},
		outPower() {
			return this.homePower + this.pvExport + this.batteryCharge;
		},
		detailsAlwaysOpen() {
			return true;
		},
		detailsHeight() {
			if (this.detailsAlwaysOpen) {
				return "auto";
			}
			return this.detailsOpen ? this.detailsCompleteHeight + "px" : 0;
		},
		batteryFmt() {
			return (soc: number) => this.fmtPercentage(soc, 0);
		},
		smartCostCo2() {
			return this.smartCostType === SMART_COST_TYPE.CO2;
		},
		pvPossible() {
			return this.pvConfigured || this.gridConfigured;
		},
		batteryGridChargeNow() {
			if (this.smartCostCo2) {
				return this.fmtCo2Short(this.tariffCo2);
			}
			return this.fmtPricePerKWh(this.tariffGrid, this.currency, true);
		},
		batteryGridChargeLimitSet() {
			return (
				this.batteryGridChargeLimit !== null && this.batteryGridChargeLimit !== undefined
			);
		},
		batteryGridChargeLimitFmt() {
			if (!this.batteryGridChargeLimitSet) {
				return;
			}
			if (this.smartCostCo2) {
				return this.fmtCo2Short(this.batteryGridChargeLimit);
			}
			return this.fmtPricePerKWh(this.batteryGridChargeLimit, this.currency, true);
		},
		solarForecastExists() {
			return !!this.forecast?.solar;
		},
		solarForecastRemainingToday() {
			if (!this.forecast?.solar) {
				return undefined;
			}
			const { today, scale } = this.forecast.solar || {};
			const factor = this.experimental && settings.solarAdjusted && scale ? scale : 1;
			const energy = today?.energy || 0;
			return energy * factor;
		},
		solarForecastIcon() {
			return this.solarForecastExists ? "forecast" : undefined;
		},
		solarForecastTooltip() {
			if (this.solarForecastExists) {
				return [this.$t("main.energyflow.forecastTooltip")];
			}
			return [];
		},
		pvExpanded() {
			return settings.energyflowPv;
		},
		batteryExpanded() {
			return settings.energyflowBattery;
		},
		consumers() {
			return [...this.aux, ...this.ext];
		},
		batteryForecastFull(): string | undefined {
			return this.fmtForecast(this.battery?.forecast, true);
		},
		batteryForecastEmpty(): string | undefined {
			return this.fmtForecast(this.battery?.forecast, false);
		},
		batteryForecastExists(): boolean {
			return !!(this.batteryForecastEmpty || this.batteryForecastFull);
		},
	},
	watch: {
		pvConfigured() {
			this.$nextTick(this.updateHeight);
		},
		gridConfigured() {
			this.$nextTick(this.updateHeight);
		},
		batteryConfigured() {
			this.$nextTick(this.updateHeight);
		},
		batteryMode() {
			this.$nextTick(this.updateHeight);
		},
	},
	mounted() {
		window.addEventListener("resize", this.updateHeight);

		// height must be calculated in case of initially open details
		if (settings.energyflowDetails) {
			this.toggleDetails();
		}
		setTimeout(() => (this.ready = true), 200);
	},
	unmounted() {
		window.removeEventListener("resize", this.updateHeight);
	},
	methods: {
		detailsValue(price?: number, co2?: number) {
			return this.showCo2 ? co2 : price;
		},
		detailsFmt(value: number) {
			return this.showCo2
				? this.fmtCo2Short(value)
				: this.fmtPricePerKWh(value, this.currency, true);
		},
		toggleCo2() {
			settings.energyflowCo2 = !settings.energyflowCo2;
		},
		forecastFmt(value: number) {
			if (typeof value !== "number") return "";
			return `${this.fmtWh(value, POWER_UNIT.KW)}`;
		},
		kw(watt: number) {
			if (typeof watt !== "number") return "";
			return this.fmtW(watt, this.powerUnit);
		},
		toggleDetails() {
			this.updateHeight();
			this.detailsOpen = !this.detailsOpen;
			settings.energyflowDetails = this.detailsOpen;
		},
		updateHeight() {
			this.detailsCompleteHeight = 0;
		},
		dischargePower(power: number) {
			return Math.abs(Math.max(0, power));
		},
		chargePower(power: number) {
			return Math.abs(Math.min(0, power) * -1);
		},
		toggleBattery() {
			settings.energyflowBattery = !settings.energyflowBattery;
			this.$nextTick(this.updateHeight);
		},
		togglePv() {
			settings.energyflowPv = !settings.energyflowPv;
			this.$nextTick(this.updateHeight);
		},
		toggleConsumers() {
			settings.energyflowConsumers = !settings.energyflowConsumers;
			this.$nextTick(this.updateHeight);
		},
		genericBatteryTitle(index: number) {
			return `${this.$t("config.devices.batteryStorage")} #${index + 1}`;
		},
		genericPvTitle(index: number) {
			return `${this.$t("config.devices.solarSystem")} #${index + 1}`;
		},
		genericConsumerTitle(index: number) {
			return `${this.$t("config.devices.consumer")} #${index + 1}`;
		},
		fmtForecast(
			forecast: { full?: string | null; empty?: string | null } | undefined,
			full: boolean
		): string | undefined {
			const isoString = full ? forecast?.full : forecast?.empty;
			if (!isoString) return undefined;
			const time = this.fmtAbsoluteDate(new Date(isoString));
			const key = full
				? "main.energyflow.batteryForecastFull"
				: "main.energyflow.batteryForecastEmpty";
			return this.$t(key, { time });
		},
	},
});
</script>
<style scoped>
.details {
	height: 0;
	opacity: 0;
	transform: scale(0.98);
	overflow: visible;
	transition-property: height, opacity, transform;
	transition-duration: 0;
	transition-timing-function: cubic-bezier(0.5, 0.5, 0.5, 1.15);
}
.details--ready {
	transition-duration: var(--evcc-transition-medium);
}
.energyflow--open .details {
	opacity: 1;
	transform: scale(1);
}
.color-grid {
	color: var(--evcc-grid);
}
.color-export {
	color: var(--evcc-export);
}
.legend-grid {
	color: var(--evcc-grid);
}
.legend-export {
	color: var(--evcc-export);
}
.legend-pv {
	color: var(--evcc-pv);
}
.legend-self {
	position: relative;
}
.legend-battery {
	position: absolute;
	top: 0;
	left: 0;
	color: var(--evcc-battery);
}
.legend-battery--mixed {
	clip-path: polygon(100% 0, 100% 100%, 0 100%);
}
</style>
