sed -i 's|_ "github.com/evcc-io/evcc/charger"|// _ "github.com/evcc-io/evcc/charger"|g' cmd/setup.go
sed -i 's|_ "github.com/evcc-io/evcc/charger"|// _ "github.com/evcc-io/evcc/charger"|g' cmd/root.go
sed -i 's|"github.com/evcc-io/evcc/charger"|// "github.com/evcc-io/evcc/charger"|g' api/globalconfig/types.go
sed -i 's|"github.com/evcc-io/evcc/charger/config"|// "github.com/evcc-io/evcc/charger/config"|g' plugin/charger.go
sed -i 's|"github.com/evcc-io/evcc/charger/openwb"|// "github.com/evcc-io/evcc/charger/openwb"|g' meter/openwb.go
sed -i 's|"github.com/evcc-io/evcc/charger/keba"|// "github.com/evcc-io/evcc/charger/keba"|g' cmd/detect/tasks/keba.go
sed -i 's|"github.com/evcc-io/evcc/charger/ocpp"|// "github.com/evcc-io/evcc/charger/ocpp"|g' api/globalconfig/types.go
