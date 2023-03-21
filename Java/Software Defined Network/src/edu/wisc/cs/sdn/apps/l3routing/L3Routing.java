package edu.wisc.cs.sdn.apps.l3routing;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.openflow.protocol.OFMatch;
import org.openflow.protocol.action.OFAction;
import org.openflow.protocol.action.OFActionOutput;
import org.openflow.protocol.instruction.OFInstruction;
import org.openflow.protocol.instruction.OFInstructionApplyActions;

import edu.wisc.cs.sdn.apps.util.Host;
import edu.wisc.cs.sdn.apps.util.SwitchCommands;

import net.floodlightcontroller.core.IFloodlightProviderService;
import net.floodlightcontroller.core.IOFSwitch;
import net.floodlightcontroller.core.IOFSwitch.PortChangeType;
import net.floodlightcontroller.core.IOFSwitchListener;
import net.floodlightcontroller.core.ImmutablePort;
import net.floodlightcontroller.core.module.FloodlightModuleContext;
import net.floodlightcontroller.core.module.FloodlightModuleException;
import net.floodlightcontroller.core.module.IFloodlightModule;
import net.floodlightcontroller.core.module.IFloodlightService;
import net.floodlightcontroller.devicemanager.IDevice;
import net.floodlightcontroller.devicemanager.IDeviceListener;
import net.floodlightcontroller.devicemanager.IDeviceService;
import net.floodlightcontroller.linkdiscovery.ILinkDiscoveryListener;
import net.floodlightcontroller.linkdiscovery.ILinkDiscoveryService;
import net.floodlightcontroller.routing.Link;

public class L3Routing implements IFloodlightModule, IOFSwitchListener, 
		ILinkDiscoveryListener, IDeviceListener
{
	public static final String MODULE_NAME = L3Routing.class.getSimpleName();
	
	// Interface to the logging system
    private static Logger log = LoggerFactory.getLogger(MODULE_NAME);
    
    // Interface to Floodlight core for interacting with connected switches
    private IFloodlightProviderService floodlightProv;

    // Interface to link discovery service
    private ILinkDiscoveryService linkDiscProv;

    // Interface to device manager service
    private IDeviceService deviceProv;
    
    // Switch table in which rules should be installed
    public static byte table;
    
    // Map of hosts to devices
    private Map<IDevice,Host> knownHosts;

	/**
     * Loads dependencies and initializes data structures.
     */
	@Override
	public void init(FloodlightModuleContext context)
			throws FloodlightModuleException 
	{
		log.info(String.format("Initializing %s...", MODULE_NAME));
		Map<String,String> config = context.getConfigParams(this);
        table = Byte.parseByte(config.get("table"));
        
		this.floodlightProv = context.getServiceImpl(
				IFloodlightProviderService.class);
        this.linkDiscProv = context.getServiceImpl(ILinkDiscoveryService.class);
        this.deviceProv = context.getServiceImpl(IDeviceService.class);
        
        this.knownHosts = new ConcurrentHashMap<IDevice,Host>();
	}

	/**
     * Subscribes to events and performs other startup tasks.
     */
	@Override
	public void startUp(FloodlightModuleContext context)
			throws FloodlightModuleException 
	{
		log.info(String.format("Starting %s...", MODULE_NAME));
		this.floodlightProv.addOFSwitchListener(this);
		this.linkDiscProv.addListener(this);
		this.deviceProv.addListener(this);
		
		/*********************************************************************/
		/*  */
		
		/*********************************************************************/
	}

	private Map<Long, Integer> optimalRouting(IOFSwitch hostSwitch) {

		Map<Long, Integer> queueOne = new ConcurrentHashMap<Long, Integer>();
		Queue<Long> longQueue = new LinkedList<Long>();
		Map<Long, Integer> queueTwo = new ConcurrentHashMap<Long,Integer>();
		Collection<Link> linkage;

		for (IOFSwitch switchVals : this.getSwitches().values()) {
	    	queueOne.put(switchVals.getId(), Integer.MAX_VALUE);
	    }

		queueOne.put(hostSwitch.getId(), 0);
		
		
	
		for (int i = 0; i < this.getSwitches().size(); i++) {
			Collection<Link> allLinks = new ArrayList<Link>();
			boolean bool;
			//duplicated links
			for (Link oneLink : this.getLinks()) {
				bool = false;
				for (Link inLink : allLinks){
					if (oneLink.getSrc() == inLink.getDst() && oneLink.getDst() == inLink.getSrc() || oneLink.getDst() == inLink.getDst() && oneLink.getSrc() == inLink.getSrc()){
						bool = true;
						break;
					}
				}
				if (!bool) {
					allLinks.add(oneLink);
				}
			}
			linkage = allLinks;

			longQueue.add(hostSwitch.getId());
			//check if queue is not empty
			while (!longQueue.isEmpty()) {
				long numID = longQueue.remove();
				Collection<Link> test = new ArrayList<Link>();
				for (Link linker : linkage) {
					if (linker.getSrc() == numID || linker.getDst() == numID) {
						test.add(linker);
					}
				}
				Collection<Link> newLinkage = test;
				for (Link copy : newLinkage) {
					int rnVal = queueOne.get(numID);
					int nextVal = Integer.MAX_VALUE;

					if (numID == copy.getSrc()) {
						nextVal = queueOne.get(copy.getDst());
						if (nextVal > (rnVal + 1)) {
							queueOne.put(copy.getDst(), (rnVal + 1));
							queueTwo.put(copy.getDst(), copy.getDstPort());
						}
						longQueue.add(copy.getDst());
					}
					else {
						nextVal = queueOne.get(copy.getSrc());
						if (nextVal > (rnVal + 1)) {
							queueOne.put(copy.getSrc(), (rnVal + 1));
							queueTwo.put(copy.getSrc(), copy.getSrcPort());
						}
						longQueue.add(copy.getDst());
					}
					linkage.remove(copy);
				}
			}
		}
		return queueTwo;
	}

	
    /**
     * Get a list of all known hosts in the network.
     */
    private Collection<Host> getHosts()
    { return this.knownHosts.values(); }
	
    /**
     * Get a map of all active switches in the network. Switch DPID is used as
     * the key.
     */
	private Map<Long, IOFSwitch> getSwitches()
    { return floodlightProv.getAllSwitchMap(); }
	
    /**
     * Get a list of all active links in the network.
     */
    private Collection<Link> getLinks()
    { return linkDiscProv.getLinks().keySet(); }

    /**
     * Event handler called when a host joins the network.
     * @param device information about the host
     */
	@Override
	public void deviceAdded(IDevice device) 
	{
		Host host = new Host(device, this.floodlightProv);
		// We only care about a new host if we know its IP
		if (host.getIPv4Address() != null)
		{
			log.info(String.format("Host %s added", host.getName()));
			this.knownHosts.put(device, host);
			
			/*****************************************************************/
			/* Update routing: add rules to route to new host          */
			if (host.isAttachedToSwitch()) {
				Map<Long, Integer> routes = optimalRouting(host.getSwitch());
				OFMatch check = new OFMatch();
				check.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				check.setNetworkDestination(host.getIPv4Address());
				OFMatch real = check;
				//keyset for view set of all keys in the map
				for (Long idVals : routes.keySet()) {
					OFAction newOF = new OFActionOutput(routes.get(idVals));
					OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
					SwitchCommands.installRule(this.getSwitches().get(idVals), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
				}

				OFAction newOF = new OFActionOutput(host.getPort());
				OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
				SwitchCommands.installRule(host.getSwitch(), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));

			}
			/*****************************************************************/
		}
	}

	/**
     * Event handler called when a host is no longer attached to a switch.
     * @param device information about the host
     */
	@Override
	public void deviceRemoved(IDevice device) 
	{
		Host host = this.knownHosts.get(device);
		if (null == host)
		{ return; }
		this.knownHosts.remove(device);
		
		log.info(String.format("Host %s is no longer attached to a switch", 
				host.getName()));
		
		/*********************************************************************/
		/*               */

		

		for (IOFSwitch switchesVal : this.getSwitches().values()) {
			OFMatch ofMatchVal = new OFMatch();
			ofMatchVal.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
			ofMatchVal.setNetworkDestination(host.getIPv4Address());
			SwitchCommands.removeRules(switchesVal, this.table, ofMatchVal);

		}
		

		/*********************************************************************/
	}

	/**
     * Event handler called when a host moves within the network.
     * @param device information about the host
     */
	@Override
	public void deviceMoved(IDevice device) 
	{
		Host host = this.knownHosts.get(device);
		if (null == host)
		{
			host = new Host(device, this.floodlightProv);
			this.knownHosts.put(device, host);
		}
		
		if (!host.isAttachedToSwitch())
		{
			this.deviceRemoved(device);
			return;
		}
		log.info(String.format("Host %s moved to s%d:%d", host.getName(),
				host.getSwitch().getId(), host.getPort()));
		
		/*********************************************************************/
		/*              */


		for (IOFSwitch switchesVal : this.getSwitches().values()) {
			OFMatch ofMatchVal = new OFMatch();
			ofMatchVal.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
			ofMatchVal.setNetworkDestination(host.getIPv4Address());
			OFMatch real = ofMatchVal;
			SwitchCommands.removeRules(switchesVal, this.table, real);

		}


		if (host.isAttachedToSwitch()) {
			Map<Long, Integer> routes = optimalRouting(host.getSwitch());
			OFMatch check = new OFMatch();
			check.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
			check.setNetworkDestination(host.getIPv4Address());
			OFMatch real = check;

			for (Long idVals : routes.keySet()) {
				OFAction newOF = new OFActionOutput(routes.get(idVals));
				OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
				SwitchCommands.installRule(this.getSwitches().get(idVals), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
			}

			OFAction newOF = new OFActionOutput(host.getPort());
			OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
			SwitchCommands.installRule(host.getSwitch(), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));

		}


		
		/*********************************************************************/
	}
	
    /**
     * Event handler called when a switch joins the network.
     * @param DPID for the switch
     */
	@Override		
	public void switchAdded(long switchId) 
	{
		IOFSwitch sw = this.floodlightProv.getSwitch(switchId);
		log.info(String.format("Switch s%d added", switchId));
		
		/*********************************************************************/
		/*          */


		for (Host host : this.getHosts()) {

			for (IOFSwitch switchesVal : this.getSwitches().values()){
				OFMatch ofMatchVal = new OFMatch();
				ofMatchVal.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				ofMatchVal.setNetworkDestination(host.getIPv4Address());
				OFMatch real = ofMatchVal;
				SwitchCommands.removeRules(switchesVal, this.table, real);
	
			}
	
	
			if(host.isAttachedToSwitch()){
				Map<Long, Integer> routes = optimalRouting(host.getSwitch());
				OFMatch check = new OFMatch();
				check.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				check.setNetworkDestination(host.getIPv4Address());
				OFMatch real = check;
	
				for (Long idVals : routes.keySet()) {
					OFAction newOF = new OFActionOutput(routes.get(idVals));
					OFInstruction testingWork = new OFInstructionApplyActions(Arrays.asList(newOF));
					OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
					SwitchCommands.installRule(this.getSwitches().get(idVals), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
				}
	
				OFAction newOF = new OFActionOutput(host.getPort());
				OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
				SwitchCommands.installRule(host.getSwitch(), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
	
			}
	
			}
		/*********************************************************************/
	}

	/**
	 * Event handler called when a switch leaves the network.
	 * @param DPID for the switch
	 *
	 */
	@Override
	public void switchRemoved(long switchId) 
	{
		IOFSwitch sw = this.floodlightProv.getSwitch(switchId);
		log.info(String.format("Switch s%d removed", switchId));
		
		/*********************************************************************/
		/*      */

		for (Host host : this.getHosts()) {

			for (IOFSwitch switchesVal : this.getSwitches().values()){
				OFMatch ofMatchVal = new OFMatch();
				ofMatchVal.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				ofMatchVal.setNetworkDestination(host.getIPv4Address());
				OFMatch real = ofMatchVal;
				SwitchCommands.removeRules(switchesVal, this.table, real);
	
			}
	
	
			if(host.isAttachedToSwitch()){
				Map<Long, Integer> routes = optimalRouting(host.getSwitch());
				OFMatch check = new OFMatch();
				check.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				check.setNetworkDestination(host.getIPv4Address());
				OFMatch real = check;
	
				for (Long idVals : routes.keySet()) {
					OFAction newOF = new OFActionOutput(routes.get(idVals));
					OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
					SwitchCommands.installRule(this.getSwitches().get(idVals), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
				}
	
				OFAction newOF = new OFActionOutput(host.getPort());
				OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
				SwitchCommands.installRule(host.getSwitch(), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
	
			}
	
			}
		
		/*********************************************************************/
	}

	/**
	 * Event handler called when multiple links go up or down.
	 * @param updateList information about the change in each link's state
	 */
	@Override
	public void linkDiscoveryUpdate(List<LDUpdate> updateList) 
	{
		for (LDUpdate update : updateList)
		{
			// If we only know the switch & port for one end of the link, then
			// the link must be from a switch to a host
			if (0 == update.getDst())
			{
				log.info(String.format("Link s%s:%d -> host updated", 
					update.getSrc(), update.getSrcPort()));
			}
			// Otherwise, the link is between two switches
			else
			{
				log.info(String.format("Link s%s:%d -> s%s:%d updated", 
					update.getSrc(), update.getSrcPort(),
					update.getDst(), update.getDstPort()));
			}
		}
		
		/*********************************************************************/
		/*        */

		for (Host host : this.getHosts()) {

			for (IOFSwitch switchesVal : this.getSwitches().values()){
				OFMatch ofMatchVal = new OFMatch();
				ofMatchVal.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				ofMatchVal.setNetworkDestination(host.getIPv4Address());
				OFMatch real = ofMatchVal;
				SwitchCommands.removeRules(switchesVal, this.table, real);
	
			}
	
	
			if(host.isAttachedToSwitch()){
				Map<Long, Integer> routes = optimalRouting(host.getSwitch());
				OFMatch check = new OFMatch();
				check.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
				check.setNetworkDestination(host.getIPv4Address());
				OFMatch real = check;
	
				for (Long idVals : routes.keySet()) {
					OFAction newOF = new OFActionOutput(routes.get(idVals));
					OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
					SwitchCommands.installRule(this.getSwitches().get(idVals), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
				}
	
				OFAction newOF = new OFActionOutput(host.getPort());
				OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOF));
				SwitchCommands.installRule(host.getSwitch(), this.table, SwitchCommands.DEFAULT_PRIORITY, real, Arrays.asList(actionRoute));
	
			}
	
			}


		
		/*********************************************************************/
	}

	/**
	 * Event handler called when link goes up or down.
	 * @param update information about the change in link state
	 */
	@Override
	public void linkDiscoveryUpdate(LDUpdate update) 
	{ this.linkDiscoveryUpdate(Arrays.asList(update)); }
	
	/**
     * Event handler called when the IP address of a host changes.
     * @param device information about the host
     */
	@Override
	public void deviceIPV4AddrChanged(IDevice device) 
	{ this.deviceAdded(device); }

	/**
     * Event handler called when the VLAN of a host changes.
     * @param device information about the host
     */
	@Override
	public void deviceVlanChanged(IDevice device) 
	{ /* Nothing we need to do, since we're not using VLANs */ }
	
	/**
	 * Event handler called when the controller becomes the master for a switch.
	 * @param DPID for the switch
	 */
	@Override
	public void switchActivated(long switchId) 
	{ /* Nothing we need to do, since we're not switching controller roles */ }

	/**
	 * Event handler called when some attribute of a switch changes.
	 * @param DPID for the switch
	 */
	@Override
	public void switchChanged(long switchId) 
	{ /* Nothing we need to do */ }
	
	/**
	 * Event handler called when a port on a switch goes up or down, or is
	 * added or removed.
	 * @param DPID for the switch
	 * @param port the port on the switch whose status changed
	 * @param type the type of status change (up, down, add, remove)
	 */
	@Override
	public void switchPortChanged(long switchId, ImmutablePort port,
			PortChangeType type) 
	{ /* Nothing we need to do, since we'll get a linkDiscoveryUpdate event */ }

	/**
	 * Gets a name for this module.
	 * @return name for this module
	 */
	@Override
	public String getName() 
	{ return this.MODULE_NAME; }

	/**
	 * Check if events must be passed to another module before this module is
	 * notified of the event.
	 */
	@Override
	public boolean isCallbackOrderingPrereq(String type, String name) 
	{ return false; }

	/**
	 * Check if events must be passed to another module after this module has
	 * been notified of the event.
	 */
	@Override
	public boolean isCallbackOrderingPostreq(String type, String name) 
	{ return false; }
	
    /**
     * Tell the module system which services we provide.
     */
	@Override
	public Collection<Class<? extends IFloodlightService>> getModuleServices() 
	{ return null; }

	/**
     * Tell the module system which services we implement.
     */
	@Override
	public Map<Class<? extends IFloodlightService>, IFloodlightService> 
			getServiceImpls() 
	{ return null; }

	/**
     * Tell the module system which modules we depend on.
     */
	@Override
	public Collection<Class<? extends IFloodlightService>> 
			getModuleDependencies() 
	{
		Collection<Class<? extends IFloodlightService >> floodlightService =
	            new ArrayList<Class<? extends IFloodlightService>>();
        floodlightService.add(IFloodlightProviderService.class);
        floodlightService.add(ILinkDiscoveryService.class);
        floodlightService.add(IDeviceService.class);
        return floodlightService;
	}
}
