export namespace KSysGuard {
  // based on https://github.com/KDE/libksysguard/blob/master/formatter/Unit.h
  export enum MetricPrefix {
    MetricPrefixAutoAdjust = -1,
    MetricPrefixUnity = 0,
    MetricPrefixKilo,
    MetricPrefixMega,
    MetricPrefixGiga,
    MetricPrefixTera,
    MetricPrefixPeta,
    MetricPrefixLast = MetricPrefixPeta,
  }

  export enum Unit {
    UnitInvalid = -1,
    UnitNone = 0,

    // Byte size units.
    UnitByte = 100,
    UnitKiloByte = MetricPrefix.MetricPrefixKilo + UnitByte,
    UnitMegaByte = MetricPrefix.MetricPrefixMega + UnitByte,
    UnitGigaByte = MetricPrefix.MetricPrefixGiga + UnitByte,
    UnitTeraByte = MetricPrefix.MetricPrefixTera + UnitByte,
    UnitPetaByte = MetricPrefix.MetricPrefixPeta + UnitByte,

    // Data rate units.
    UnitByteRate = 200,
    UnitKiloByteRate = MetricPrefix.MetricPrefixKilo + UnitByteRate,
    UnitMegaByteRate = MetricPrefix.MetricPrefixMega + UnitByteRate,
    UnitGigaByteRate = MetricPrefix.MetricPrefixGiga + UnitByteRate,
    UnitTeraByteRate = MetricPrefix.MetricPrefixTera + UnitByteRate,
    UnitPetaByteRate = MetricPrefix.MetricPrefixPeta + UnitByteRate,

    // Frequency.
    UnitHertz = 300,
    UnitKiloHertz = MetricPrefix.MetricPrefixKilo + UnitHertz,
    UnitMegaHertz = MetricPrefix.MetricPrefixMega + UnitHertz,
    UnitGigaHertz = MetricPrefix.MetricPrefixGiga + UnitHertz,
    UnitTeraHertz = MetricPrefix.MetricPrefixTera + UnitHertz,
    UnitPetaHertz = MetricPrefix.MetricPrefixPeta + UnitHertz,

    // Time units.
    UnitBootTimestamp = 400,
    UnitSecond,
    UnitTime,
    UnitTicks,
    UnitDuration,

    // Data rate units in bits.
    UnitBitRate = 500,
    UnitKiloBitRate = MetricPrefix.MetricPrefixKilo + UnitBitRate,
    UnitMegaBitRate = MetricPrefix.MetricPrefixMega + UnitBitRate,
    UnitGigaBitRate = MetricPrefix.MetricPrefixGiga + UnitBitRate,
    UnitTeraBitRate = MetricPrefix.MetricPrefixTera + UnitBitRate,
    UnitPetaBitRate = MetricPrefix.MetricPrefixPeta + UnitBitRate,

    // Volt.
    UnitVolt = 600,
    UnitKiloVolt = MetricPrefix.MetricPrefixKilo + UnitVolt,
    UnitMegaVolt = MetricPrefix.MetricPrefixMega + UnitVolt,
    UnitGigaVolt = MetricPrefix.MetricPrefixGiga + UnitVolt,
    UnitTeraVolt = MetricPrefix.MetricPrefixTera + UnitVolt,
    UnitPetaVolt = MetricPrefix.MetricPrefixPeta + UnitVolt,

    // Watt.
    UnitWatt = 700,
    UnitKiloWatt = MetricPrefix.MetricPrefixKilo + UnitWatt,
    UnitMegaWatt = MetricPrefix.MetricPrefixMega + UnitWatt,
    UnitGigaWatt = MetricPrefix.MetricPrefixGiga + UnitWatt,
    UnitTeraWatt = MetricPrefix.MetricPrefixTera + UnitWatt,
    UnitPetaWatt = MetricPrefix.MetricPrefixPeta + UnitWatt,

    // WattHour.
    UnitWattHour = 800,
    UnitKiloWattHour = MetricPrefix.MetricPrefixKilo + UnitWattHour,
    UnitMegaWattHour = MetricPrefix.MetricPrefixMega + UnitWattHour,
    UnitGigaWattHour = MetricPrefix.MetricPrefixGiga + UnitWattHour,
    UnitTeraWattHour = MetricPrefix.MetricPrefixTera + UnitWattHour,
    UnitPetaWattHour = MetricPrefix.MetricPrefixPeta + UnitWattHour,

    // Ampere.
    UnitAmpere = 900,
    UnitKiloAmpere = MetricPrefix.MetricPrefixKilo + UnitAmpere,
    UnitMegaAmpere = MetricPrefix.MetricPrefixMega + UnitAmpere,
    UnitGigaAmpere = MetricPrefix.MetricPrefixGiga + UnitAmpere,
    UnitTeraAmpere = MetricPrefix.MetricPrefixTera + UnitAmpere,
    UnitPetaAmpere = MetricPrefix.MetricPrefixPeta + UnitAmpere,

    // Misc units.
    UnitCelsius = 1000,
    UnitDecibelMilliWatts,
    UnitPercent,
    UnitRate,
    UnitRpm,
  }

  // source: https://github.com/KDE/libksysguard/blob/master/sensors/Sensor.h
  export enum Status {
    /** The sensor has no ID assigned. */
    Unknown,
    /** The sensor is currently being loaded. */
    Loading,
    /** The sensor has been loaded. */
    Ready,
    /** An error occurred or the sensor has been removed. */
    Error,
    /** Removed from backend */
    Removed,
  }

  // source: https://github.com/KDE/libksysguard/blob/master/sensors/Sensor.h
  /**
   * An object encapsulating a backend sensor.
   *
   * This class represents a sensor as exposed by the backend. It allows querying
   * various metadata properties of the sensor as well as the current value.
   */
  export declare class Sensor {
    // bool event(QEvent *event) override;

    /** The path to the backend sensor this Sensor represents. */
    readonly sensorId: QString;
    setSensorId(id: QString): void;
    readonly sensorIdChanged: Signal<() => void>;

    /**
     * The status of the sensor.
     *
     * Due to the asynchronous nature of the underlying code, sensors are not
     * immediately available on construction. Instead, they need to request data
     * from the daemon and wait for it to arrive. This property reflects where
     * in that process this sensor is.
     */
    readonly status: KSysGuard.Status;
    readonly statusChanged: Signal<() => void>;

    /** The user-visible name of this Sensor. */
    readonly name: QString;
    /**
     * A shortened name that can be displayed when space is constrained.
     *
     * The value is the same as name if shortName was not provided by the backend.
     */
    readonly shortName: QString;
    /** A description of the Sensor. */
    readonly description: QString;
    /** The unit of this Sensor. */
    readonly unit: KSysGuard.Unit;
    /** The minimum value this Sensor can have. */
    readonly minimum: qreal;
    /** The maximum value this Sensor can have. */
    readonly maximum: qreal;
    /**
     * The QVariant type for this sensor.
     *
     * This is used to create proper default values.
     */
    // readonly type: QVariant.Type;
    /** This signal is emitted when any of the metadata properties change. */
    metaDataChanged(): Signal<() => void>;

    /**
     * Returns the output of the sensor.
     *
     * The returned value is the most recent sensor data received from the ksysguard
     * daemon, it's not necessarily the actual current output value.
     *
     * The client can't control how often the sensor data is sampled. The ksysguard
     * daemon is in charge of picking the sample rate. When the Sensor receives new
     * output value, dataChanged signal will be emitted.
     *
     * @see dataChanged
     */
    readonly value: QVariant;
    /** A formatted version of `property` value. */
    readonly formattedValue: QString;
    valueChanged(): Signal<() => void>;

    /**
     * Should this Sensor check for changes?
     *
     * Note that if set to true, the sensor will only be enabled when the parent
     * is also enabled.
     */
    readonly enabled: bool;
    setEnabled(newEnabled: bool): void;
    enabledChanged: Signal<() => void>;

    /**
     * The time in milliseconds between each update of the sensor.
     *
     * This is primarily intended to match sampling rate to the update rate of
     * the sensor, like when used by KQuickCharts's HistorySource.
     *
     * \note Currently, the update rate of the backend is fixed and this method
     *       simply matches the value from the backend. Eventually the idea is
     *       that we can support per-sensor update rates.
     */
    readonly updateInterval: uint;
    updateIntervalChanged: Signal<() => void>;

    /**
     * The minimum time between updates, in milliseconds.
     *
     * If this is set to a positive non-zero value, at least this many
     * milliseconds need to elapse before another value update happens, otherwise
     * it is ignored. This effectively rate-limits the updates and will prevent
     * value updates.
     */
    updateRateLimit: int;
    setUpdateRateLimit(newUpdateRateLimit: int): void;
    resetUpdateRateLimit(): void;
    updateRateLimitChanged: Signal<() => void>;
  }

  // source: https://github.com/KDE/libksysguard/blob/master/formatter/FormatterWrapper.h
  /**
   * Tiny helper class to make Formatter usable from QML.
   *
   * An instance of this class will be exposed as a Singleton object to QML. It
   * allows formatting of values from the QML side.
   *
   * This effectively wraps Formatter::formatValue, removing the FormatOptions flag
   * that I couldn't get to work.
   *
   * It is accessible as `Formatter` inside the `org.kde.ksysguard.formatter` package
   * @see Formatter
   */
  export declare class FormatterWrapper {
    static formatValue(
      value: QVariant,
      unit: KSysGuard.Unit,
      targetPrefix?: KSysGuard.MetricPrefix,
    ): QString;

    static formatValueShowNull(
      value: QVariant,
      unit: KSysGuard.Unit,
      targetPrefix?: KSysGuard.MetricPrefix,
    ): QString;

    static formatValueWithPrecision(
      value: QVariant,
      unit: KSysGuard.Unit,
      precision?: int,
    ): QString;

    static maximumLength(unit: KSysGuard.Unit, font: QFont): qreal;
  }
}
