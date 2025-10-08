import { KSysGuard } from "./typings/KSysGuard";
import deepmerge from "deepmerge";

type Formatter<TType = string, TData = {}> = {
  type: TType;
  [name: string]: any;
} & TData;

type TextFormatter = Formatter<
  "text",
  {
    text: string;
  }
>;

type IconFormatter = Formatter<
  "icon",
  {
    icon: string;
  }
>;

type SensorFormatter = Formatter<
  "sensor",
  {
    sensorId: any;
    sensorIndex: number;
  }
>;

export function buildTextFormatter(
  text: string,
  data?: Record<string, any>,
): TextFormatter {
  return {
    ...data,
    type: "text",
    text,
  };
}

export function buildIconFormatter(
  icon: string,
  data?: Record<string, any>,
): IconFormatter {
  return {
    ...data,
    type: "icon",
    icon,
  };
}

export function buildSensorFormatter(
  sensorId: string,
  sensorIndex: number,
  data?: Record<string, any>,
): SensorFormatter {
  return {
    ...data,
    type: "sensor",
    sensorId,
    sensorIndex,
    precision: data?.["precision"] ?? 1,
  };
}

export function buildErrorFormatter(error: any): TextFormatter {
  console.error(error);
  return buildTextFormatter(
    typeof error === "string"
      ? error
      : error instanceof Error
      ? error.message
      : "Error",
  );
}

export function isFormatter(value: any): value is Formatter {
  return (
    typeof value === "object" &&
    "type" in value &&
    typeof value.type === "string"
  );
}

export function isTextFormatter(value: any): value is TextFormatter {
  return (
    isFormatter(value) &&
    value.type === "text" &&
    "text" in value &&
    typeof value["text"] === "string"
  );
}

export function isIconFormatter(value: any): value is IconFormatter {
  return (
    isFormatter(value) &&
    value.type === "icon" &&
    "icon" in value &&
    typeof value["icon"] === "string"
  );
}

export function isSensorFormatter(value: any): value is SensorFormatter {
  return (
    isFormatter(value) &&
    value.type === "sensor" &&
    "sensorIndex" in value &&
    typeof value["sensorIndex"] === "number"
  );
}

const DELETE_KEYWORDS = [
  "type",
  "sensorId",
  "sensorIndex",
  "precision",
  "icon",
  "iconSize",
  "leadingZeros",
];

// TODO: simplify and cleanup this mess

export function buildDefaultConfig(
  sensorIds: string[],
  globalFormatter?: Record<string, unknown>,
) {
  let data: Formatter[] = [];
  let sensorIndex = 0;

  for (const sensorId of sensorIds) {
    const sensor = buildSensorFormatter(sensorId, sensorIndex, globalFormatter);
    data = [...data, sensor];
    sensorIndex++;
  }
  return data;
}

export function updateConfig(
  formatter: string,
  sensorIds: string[],
  config?: string,
): Formatter[] {
  let data: Formatter[] = [];
  let sensorIndex = 0;
  let globalData: Record<string, unknown> = {};

  if (config) {
    try {
      globalData = JSON.parse(config);
      if (Array.isArray(globalData))
        throw new TypeError("Configuration must be a valid JSON object");
    } catch (e) {
      return [buildErrorFormatter(e)];
    }
  }

  if (!formatter) return buildDefaultConfig(sensorIds, globalData);

  try {
    data = JSON.parse(formatter);
    if (!Array.isArray(data))
      throw new TypeError("Formatter must be a valid JSON array");
  } catch (e) {
    return [buildErrorFormatter(e)];
  }

  if (!data.length) return buildDefaultConfig(sensorIds, globalData);

  return data.map((i) => {
    if (Array.isArray(i)) {
      return buildErrorFormatter("Array inside of formatter");
    } else if (typeof i !== "object") {
      return buildTextFormatter(i, globalData);
    }

    const json: Record<string, unknown> = deepmerge(globalData, i);
    let idx = sensorIndex;

    if (!isFormatter(json)) return buildErrorFormatter("Invalid object");

    switch (json.type) {
      case "text":
        json["text"] ??= "";
        break;

      case "icon":
        if (!("icon" in json) || typeof json["icon"] !== "string")
          return buildErrorFormatter("Missing icon field");
        break;

      case "sensor":
        if ("sensorIndex" in json && typeof json["sensorIndex"] === "number") {
          idx = json["sensorIndex"];
        } else {
          sensorIndex++;
        }

        if (sensorIds[idx] === undefined)
          return buildErrorFormatter("Sensor out of bounds");

        return buildSensorFormatter(
          json["sensorId"] ?? sensorIds[idx]!,
          idx,
          json,
        );

      default:
        return buildErrorFormatter("Unsupported type");
    }

    return json;
  });
}

export function applyConfigToComponent(
  component: any,
  modelData: Formatter,
  sensor: KSysGuard.Sensor | null,
  sensors: KSysGuard.Sensor[],
  kirigami: Record<string, unknown>,
) {
  if (!sensors?.length) return;

  const data = { ...modelData };

  for (const i of DELETE_KEYWORDS) delete data[i];

  Object.entries(data).forEach(([key, value]) => {
    if (!(key in component)) return;

    // regex here, it breaks if placed on top of the file
    const FUNCTION_REGEX = /^(\(.*\)\s*=>|function\(.*\)\s*{)/g;

    if (typeof value === "string" && FUNCTION_REGEX.test(value)) {
      const fn = new Function(
        "sensor",
        "sensors",
        "config",
        "kirigami",
        `return (() => (${value})(sensor, sensors, config, kirigami))`,
      );
      value = Qt.binding(fn(sensor, sensors, modelData, kirigami));
    }

    component[key] = value;
  });
}

export function format(
  modelData: Formatter,
  sensor: KSysGuard.Sensor,
  formatter: typeof KSysGuard.FormatterWrapper,
) {
  if (!modelData) return "";

  if (isTextFormatter(modelData)) return i18n("%1", modelData.text);

  let val = formatter.formatValueWithPrecision(
    sensor.value,
    sensor.unit,
    modelData["precision"],
  );

  // const pad = Math.max(
  //   0,
  //   (modelData["leadingZeros"] ?? 0) - `${Math.round(sensor.value)}`.length,
  // );

  // return i18n("%1", val.padStart(val.length + pad, "0"));

  return i18n("%1", val);
}

export function onSensorAdded(
  index: number,
  sensor: KSysGuard.Sensor,
  sensors: KSysGuard.Sensor[],
) {
  return [...sensors.slice(0, index), sensor, ...sensors.slice(index)];
}

export function onSensorRemoved(
  index: number,
  sensor: KSysGuard.Sensor,
  sensors: KSysGuard.Sensor[],
) {
  return sensors.filter((_, idx) => idx !== index);
}
