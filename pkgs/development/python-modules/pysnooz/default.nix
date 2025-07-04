{
  lib,
  bleak,
  bleak-retry-connector,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  events,
  fetchFromGitHub,
  freezegun,
  home-assistant-bluetooth,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
  transitions,
}:

buildPythonPackage rec {
  pname = "pysnooz";
  version = "0.10.0";
  format = "pyproject";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "AustinBrunkhorst";
    repo = "pysnooz";
    tag = "v${version}";
    hash = "sha256-jOXmaJprU35sdNRrBBx/YUyiDyyaE1qodWksXkTSEe0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'transitions = "^0.8.11"' 'transitions = ">=0.8.11"' \
      --replace 'Events = "^0.4"' 'Events = ">=0.4"'
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    bleak
    bleak-retry-connector
    bluetooth-sensor-state-data
    events
    home-assistant-bluetooth
    transitions
  ];

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
  ];

  pythonImportsCheck = [ "pysnooz" ];

  meta = with lib; {
    description = "Library to control SNOOZ white noise machines";
    homepage = "https://github.com/AustinBrunkhorst/pysnooz";
    changelog = "https://github.com/AustinBrunkhorst/pysnooz/blob/v${version}/CHANGELOG.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
