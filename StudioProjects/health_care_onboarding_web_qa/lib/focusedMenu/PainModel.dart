
enum PainType {
  Cramping,
  Sharp,
  Throbbing,
  Burning,
  Radicular,
  Dull_Heavy,
  None,
  Init
}

PainType StringToType(String type) {
  switch (type) {
    case 'CRAMPING':
      return PainType.Cramping;
    case 'SHARP':
      return PainType.Sharp;
    case 'THROBBING':
      return PainType.Throbbing;
    case 'BURNING':
      return PainType.Burning;
    case 'RADICULAR':
      return PainType.Radicular;
    case 'DULL_HEAVY':
      return PainType.Dull_Heavy;
    default:
      return PainType.None;
  }
}

String TypeTOString(PainType type) {
  switch (type) {
    case PainType.Cramping:
      return 'CRAMPING';
    case PainType.Sharp:
      return 'SHARP';
    case PainType.Throbbing:
      return 'THROBBING';
    case PainType.Burning:
      return 'BURNING';
    case PainType.Radicular:
      return 'RADICULAR';
    case PainType.Dull_Heavy:
      return 'DULL_HEAVY';
    default:
      return 'None';
  }
}

class PainModel {

  PainModel(this.painLvl, this.painType);
  int? painLvl;
  PainType? painType;
}

class PainModelBuilder {

  PainModelBuilder();
  int? painLvl;
  PainType? painType;

  PainModelBuilder withPainLevel(int? level) {
    this.painLvl = level;
    return this;
  }

  PainModelBuilder withPainType(PainType? type) {
    this.painType = type;
    return this;
  }

  PainModel build() {
    return PainModel(painLvl ?? 0, painType ?? PainType.None);
  }
}
