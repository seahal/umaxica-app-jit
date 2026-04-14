import coverageV8 from "@vitest/coverage-v8";
import vitePlusPackage from "vite-plus/package.json" with { type: "json" };

const { startCoverage, stopCoverage, takeCoverage } = coverageV8;

export default {
  startCoverage,
  stopCoverage,
  takeCoverage,
  async getProvider() {
    const provider = await coverageV8.getProvider();

    // Align the provider version with Vite+ test to avoid mixed-version warnings.
    provider.version = vitePlusPackage.version;

    return provider;
  },
};
