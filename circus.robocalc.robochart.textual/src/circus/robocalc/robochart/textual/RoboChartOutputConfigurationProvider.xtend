package circus.robocalc.robochart.textual

import circus.robocalc.robochart.textual.generator.AbstractRoboChartGenerator
import org.eclipse.core.runtime.Platform
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.generator.OutputConfigurationProvider

/**
 * This class searches for all robochart generators provided by plugins,
 * and creates output configurations based on the identifier and folder
 * associated with the generator.
 * 
 * @author Alvaro Miyazawa
 * @version 1.0
 * @since 11.0
 * @see AbstractRoboChartGenerator
 */
class RoboChartOutputConfigurationProvider extends OutputConfigurationProvider {
	public static val NOT_DERIVED = "NOT_DERIVED"
	public static val DERIVED = "DERIVED"

	static val GEN_ID = "robochart.generator"
	
	override getOutputConfigurations() {
		val config = Platform.extensionRegistry.getConfigurationElementsFor(GEN_ID);
		val ocp = super.getOutputConfigurations()
		for (e : config) {
			val folder = e.getAttribute("folder") ?: "src-gen"
			val o = e.createExecutableExtension("class")
			if (o instanceof AbstractRoboChartGenerator) {
				val dc = new OutputConfiguration(o.ID);
				dc.setDescription("Configuration for generator "+o.class.name);
				dc.setOutputDirectory("./"+folder);
				dc.setOverrideExistingResources(true);
				dc.setCreateOutputDirectory(true);
				dc.setCanClearOutputDirectory(true);
				dc.setCleanUpDerivedResources(true);
				dc.setSetDerivedProperty(true);
				dc.setKeepLocalHistory(true);
				ocp.add(dc)
			}
		}
		return ocp
	}
}